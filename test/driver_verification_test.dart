// Vérification du livreur — côté app.
//
// L'app ne décide rien : elle demande au serveur. Ces tests vérifient qu'elle
// demande bien, et surtout qu'elle échoue DANS LE BON SENS.
//
// Ce qui ne peut pas être testé ici : l'exclusion du dispatch, le refus
// d'acceptation, l'invisibilité du CIN. Ce sont des garanties de PostgreSQL —
// voir supabase/tests/driver_verification_test.sql.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source d'un fichier, COMMENTAIRES RETIRÉS — sans quoi une assertion
/// d'absence tombe sur le commentaire qui explique la règle.
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

const _provider =
    'lib/features/orders/providers/driver_verification_provider.dart';
const _home = 'lib/features/home/presentation/home_screen.dart';

void main() {
  group('le provider interroge le serveur', () {
    test('il appelle la RPC, il ne décide pas localement', () {
      final src = _read(_provider);
      expect(src.contains("rpc('driver_is_verified'"), isTrue);
      // Aucune lecture directe du dossier : driver_identity est admin-only,
      // une requête dessus renverrait toujours vide et ferait croire à un
      // livreur non vérifié.
      expect(src.contains('driver_identity'), isFalse,
          reason: 'la table est admin-only, le livreur ne la voit pas');
    });

    test('il échoue OUVERT, pas fermé', () {
      final src = _read(_provider);
      // En cas d'erreur ou de fonction absente, renvoyer true. Un faux négatif
      // bloquerait un livreur légitime derrière un écran d'attente alors que
      // le serveur le laisse travailler — et le vrai refus est de toute façon
      // côté base.
      expect(src.contains('catch (_) {'), isTrue);
      expect(RegExp(r'catch \(_\) \{\s*return true;').hasMatch(src), isTrue,
          reason: 'une erreur réseau ne doit pas bloquer un livreur vérifié');
    });
  });

  group("l'écran d'accueil", () {
    test('masque l\'interrupteur quand le compte n\'est pas vérifié', () {
      final src = _read(_home);
      expect(src.contains('driverIsVerifiedProvider'), isTrue);
      expect(src.contains('if (!isVerified)'), isTrue,
          reason: 'sans ce garde, le livreur bute sur une erreur serveur '
              'sans comprendre pourquoi');
    });

    test('affiche un message et un moyen de contact', () {
      final src = _read(_home);
      expect(src.contains('_VerificationPendingNotice'), isTrue);
      expect(src.contains('CIN'), isTrue);
      expect(src.contains('tel'), isTrue,
          reason: 'un livreur bloqué doit pouvoir joindre quelqu\'un tout de '
              'suite, pas chercher le numéro');
    });

    test('reste optimiste pendant le chargement', () {
      final src = _read(_home);
      // maybeWhen(..., orElse: () => true) : tant que la réponse n'est pas là,
      // on n'affiche pas un écran d'attente à tort.
      expect(src.contains('orElse: () => true'), isTrue);
    });
  });
}
