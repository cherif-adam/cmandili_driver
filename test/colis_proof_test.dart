// Bon de prise en charge Colis — garanties côté livreur.
//
// Deux familles de tests ici, et la distinction compte :
//
//   • Les tests de SOURCE lisent le code du dépôt. C'est la seule façon de
//     prouver une interdiction — « la galerie n'est jamais proposée » est une
//     propriété de tout le fichier, pas d'un appel qu'on pourrait exercer.
//   • Les tests de WIDGET montent les feuilles et vérifient ce que le livreur
//     voit réellement selon le mode de remise.
//
// Ce qui ne peut PAS être testé ici : l'immuabilité, l'invisibilité du code
// côté base, le plafond de valeur déclarée et la fenêtre de litige. Ce sont
// des garanties de la base de données, elles se vérifient avec le harnais SQL
// (voir supabase/tests/), pas depuis Flutter.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cmandili_driver/features/orders/data/colis_proof_repository.dart';
import 'package:cmandili_driver/features/orders/presentation/widgets/colis_proof_sheets.dart';

/// Le code du fichier, COMMENTAIRES RETIRÉS.
///
/// Sans ce dépouillage, l'assertion ne prouve rien : ces fichiers expliquent
/// en commentaire pourquoi ils n'utilisent ni la galerie ni getPublicUrl, et
/// une recherche naïve trouverait ces mots-là et échouerait — ou pire,
/// réussirait un jour sur un commentaire alors que le code, lui, aurait
/// changé.
String _read(String path) {
  final f = File(path);
  expect(f.existsSync(), isTrue, reason: 'fichier introuvable : $path');
  return f
      .readAsLinesSync()
      .map((l) {
        final i = l.indexOf('//');
        return i < 0 ? l : l.substring(0, i);
      })
      .join('\n');
}

const _repoPath = 'lib/features/orders/data/colis_proof_repository.dart';
const _sheetsPath = 'lib/features/orders/presentation/widgets/colis_proof_sheets.dart';

/// Dépôt instrumenté : compte les envois de photo et refuse le premier code.
/// Ni réseau ni caméra — on veut observer l'enchaînement, pas les plugins.
class _RetryProbeRepo extends ColisProofRepository {
  _RetryProbeRepo(super.client, {this.alwaysFail = false});

  final bool alwaysFail;
  int uploads = 0;
  String? firstPathIssued;
  String? lastPathUsed;
  int _verifies = 0;

  /// Écriture SYNCHRONE, volontairement. Sous flutter_test l'horloge est
  /// simulée et les vraies E/S disque ne se résolvent jamais : un
  /// `await writeAsBytes(...)` laisse le Future en suspens, capturePhoto ne
  /// rend pas la main, et _photo reste null sans la moindre erreur visible.
  @override
  Future<File?> capturePhoto() async {
    final f = File(
        '${Directory.systemTemp.path}/colis_test_${DateTime.now().microsecondsSinceEpoch}.jpg');
    f.writeAsBytesSync(<int>[0xFF, 0xD8, 0xFF]);
    addTearDown(() {
      if (f.existsSync()) f.deleteSync();
    });
    return f;
  }

  @override
  Future<Position?> currentPosition() async => null;

  @override
  Future<String> uploadProof({
    required String orderId,
    required String step,
    required File photo,
  }) async {
    uploads++;
    final p = '$orderId/${step}_$uploads.jpg';
    firstPathIssued ??= p;
    return p;
  }

  @override
  Future<void> verifyAndDeliver({
    required String orderId,
    required String photoPath,
    String? code,
  }) async {
    lastPathUsed = photoPath;
    _verifies++;
    if (alwaysFail || _verifies == 1) {
      throw const PostgrestException(message: 'Code incorrect (tentative 1 sur 5)');
    }
  }
}

void main() {
  group('appareil photo uniquement', () {
    test('la galerie n\'est jamais proposée dans le flux de preuve', () {
      for (final p in [_repoPath, _sheetsPath]) {
        final src = _read(p);
        expect(src.contains('ImageSource.gallery'), isFalse,
            reason: '$p propose la galerie : une photo choisie dans la '
                'pellicule ne prouve rien, elle peut dater de n\'importe quand');
        expect(src.contains('pickVideo'), isFalse, reason: p);
      }
    });

    test('la capture passe bien par la caméra', () {
      expect(_read(_repoPath).contains('ImageSource.camera'), isTrue);
    });
  });

  group('le code ne transite jamais par le livreur', () {
    test('le dépôt ne lit jamais la table des codes', () {
      final src = _read(_repoPath);
      expect(src.contains('colis_delivery_codes'), isFalse,
          reason: 'le livreur ne doit pas même tenter de lire les codes : '
              'la table n\'a aucune policy pour lui');
    });

    test('la vérification se fait par RPC serveur, pas en local', () {
      final src = _read(_repoPath);
      expect(src.contains('colis_verify_and_deliver'), isTrue);
      // Aucune comparaison de code côté client : pas de hash, pas d'égalité.
      expect(src.contains('sha256'), isFalse);
    });

    test('la limite affichée correspond à celle du serveur', () {
      expect(kColisMaxCodeAttempts, 5);
      expect(_read(_sheetsPath).contains('kColisMaxCodeAttempts'), isTrue);
    });
  });

  group('bucket privé', () {
    test('les preuves sont relues par URL signée, jamais publique', () {
      final src = _read(_repoPath);
      expect(src.contains('createSignedUrl'), isTrue);
      expect(src.contains('getPublicUrl'), isFalse,
          reason: 'colis-proofs est privé : getPublicUrl ne renverrait rien '
              'd\'exploitable et exposerait le chemin');
    });

    test('le chemin porte l\'identifiant de commande en premier segment', () {
      // Les policies du bucket lisent split_part(name, '/', 1).
      final src = _read(_repoPath);
      expect(src.contains("'\$orderId/"), isTrue);
      // ... et un horodatage, sinon un deuxième essai se heurte au refus de
      // doublon du stockage (voir le test de nouvel essai plus bas).
      expect(src.contains('millisecondsSinceEpoch'), isTrue,
          reason: 'le chemin doit être unique par tentative');
    });

    test('jamais d\'upsert : une preuve enregistrée ne se remplace pas', () {
      expect(_read(_repoPath).contains('upsert'), isFalse,
          reason: 'upsert permettrait d\'écraser une preuve déjà versée au '
              'reçu, ce que toute la migration s\'emploie à empêcher');
    });
  });

  group('le flux de prise en charge est bien branché', () {
    // Ce test existe parce que le câblage était faux : un colis saute l'étape
    // 'pickedUp' et passe par _parcelCollected, pas par _markPickedUp. La
    // preuve n'était donc jamais demandée pour les seules commandes qu'elle
    // protège, et rien ne le signalait.
    const screen = 'lib/features/orders/presentation/order_tracking_screen.dart';

    String bodyOf(String src, String fn) {
      final start = src.indexOf('Future<void> $fn(');
      expect(start, greaterThan(-1), reason: '$fn introuvable');
      final next = src.indexOf('\n  Future<', start + 1);
      return src.substring(start, next < 0 ? src.length : next);
    }

    test('_parcelCollected exige la preuve avant de passer en route', () {
      final body = bodyOf(_read(screen), '_parcelCollected');
      expect(body.contains('_recordColisPickupIfNeeded'), isTrue,
          reason: 'sans cet appel, un colis part sans photo ni confirmation');
      expect(body.contains('return'), isTrue,
          reason: 'le refus de preuve doit interrompre la transition');
    });

    test('_markPickedUp la demande aussi, pour les autres flux', () {
      final body = bodyOf(_read(screen), '_markPickedUp');
      expect(body.contains('_recordColisPickupIfNeeded'), isTrue);
    });

    test('la remise passe par la RPC et non par un UPDATE direct', () {
      final body = bodyOf(_read(screen), '_confirmDelivery');
      expect(body.contains('_deliverColisIfNeeded'), isTrue);
      expect(body.contains('_ColisStep.aborted'), isTrue,
          reason: 'un refus doit interrompre, pas livrer quand même');
    });
  });

  group('les feuilles de remise', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Supabase persiste la session via shared_preferences, dont le canal de
      // plateforme n'existe pas sous flutter test. Sans ce bouchon,
      // Supabase.initialize lève MissingPluginException.
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: 'http://localhost:54321',
        anonKey: 'test-anon-key',
        debug: false,
      );
    });

    Future<void> pumpDelivery(
      WidgetTester tester,
      Map<String, dynamic> receipt,
    ) async {
      final repo = ColisProofRepository(Supabase.instance.client);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showColisDeliverySheet(
                context: ctx,
                repo: repo,
                orderId: '00000000-0000-0000-0000-000000000001',
                receipt: receipt,
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ouvrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('mode code : champ à 4 chiffres et essais restants',
        (tester) async {
      await pumpDelivery(tester, {
        'delivery_mode': 'code',
        'code_attempts': 0,
        'code_locked_at': null,
      });
      expect(find.text('Remise du colis'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('essais possibles'), findsOneWidget);
    });

    testWidgets('mode sans code : pas de champ, le destinataire est nommé',
        (tester) async {
      await pumpDelivery(tester, {
        'delivery_mode': 'no_code',
        'receiver_label': "Gardien de l'école",
        'code_attempts': 0,
        'code_locked_at': null,
      });
      expect(find.text('Remise sans code'), findsOneWidget);
      expect(find.text("Gardien de l'école"), findsOneWidget);
      expect(find.byType(TextField), findsNothing,
          reason: 'aucun code à saisir dans ce mode');
    });

    testWidgets('blocage : le bouton de remise est désactivé', (tester) async {
      await pumpDelivery(tester, {
        'delivery_mode': 'code',
        'code_attempts': 5,
        'code_locked_at': '2026-10-12T10:00:00Z',
      });
      expect(find.textContaining('Trop de codes erronés'), findsOneWidget);
      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Valider le code et livrer'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('code erroné puis nouvel essai : une seule photo déposée',
        (tester) async {
      // Le bug : la photo partait à `<order>/delivery.jpg` AVANT la RPC. Code
      // refusé -> deuxième essai sur le même chemin -> le stockage refuse le
      // doublon -> « L'envoi de la photo a échoué », pour toujours.
      final repo = _RetryProbeRepo(Supabase.instance.client);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showColisDeliverySheet(
                context: ctx,
                repo: repo,
                orderId: 'o1',
                receipt: const {
                  'delivery_mode': 'code',
                  'code_attempts': 0,
                  'code_locked_at': null,
                  'sender_phone': '20000000',
                },
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ouvrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Photo prise une fois.
      // Par cle et apres ensureVisible : la feuille defile, et taper le
      // libelle echouait silencieusement quand le bouton passait sous le pli.
      await tester.ensureVisible(find.byKey(const Key('colis-delivery-photo')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('colis-delivery-photo')));
      // capturePhoto ecrit un fichier temporaire : un seul pump ne laisse pas
      // le Future aboutir, et _photo resterait null.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Premier essai : mauvais code.
      await tester.enterText(find.byType(TextField), '1111');
      await tester.tap(find.text('Valider le code et livrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Code incorrect'), findsOneWidget);
      expect(repo.uploads, 1);

      // Deuxième essai : le bon. La photo ne doit PAS repartir.
      await tester.enterText(find.byType(TextField), '2222');
      await tester.tap(find.text('Valider le code et livrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(repo.uploads, 1,
          reason: 'la photo déjà déposée doit être réutilisée, sinon le '
              'stockage refuse le doublon et le livreur reste bloqué');
      expect(repo.lastPathUsed, repo.firstPathIssued);
    });

    testWidgets('reprendre la photo force un nouveau dépôt', (tester) async {
      final repo = _RetryProbeRepo(Supabase.instance.client, alwaysFail: true);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showColisDeliverySheet(
                context: ctx,
                repo: repo,
                orderId: 'o1',
                receipt: const {
                  'delivery_mode': 'no_code',
                  'receiver_label': 'Gardien',
                  'code_attempts': 0,
                  'code_locked_at': null,
                },
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ouvrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Par cle et apres ensureVisible : la feuille defile, et taper le
      // libelle echouait silencieusement quand le bouton passait sous le pli.
      await tester.ensureVisible(find.byKey(const Key('colis-delivery-photo')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('colis-delivery-photo')));
      // capturePhoto ecrit un fichier temporaire : un seul pump ne laisse pas
      // le Future aboutir, et _photo resterait null.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Confirmer la remise'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(repo.uploads, 1);

      // Nouvelle photo : l'ancien dépôt ne la représente plus.
      await tester.tap(find.textContaining('Reprendre'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Confirmer la remise'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(repo.uploads, 2,
          reason: 'une photo reprise doit être redéposée, sinon le reçu '
              'référencerait l\'ancienne');
    });

    testWidgets('la photo est exigée avant toute validation', (tester) async {
      await pumpDelivery(tester, {
        'delivery_mode': 'no_code',
        'receiver_label': 'Gardien',
        'code_attempts': 0,
        'code_locked_at': null,
      });
      await tester.tap(find.text('Confirmer la remise'));
      await tester.pump();
      expect(find.textContaining('photo de remise est obligatoire'),
          findsOneWidget);
    });
  });
}
