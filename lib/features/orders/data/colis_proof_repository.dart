// Bon de prise en charge Colis — côté livreur.
//
// Tout passe par les RPC SECURITY DEFINER de la migration 20261012090000 :
// l'app ne peut pas écrire dans colis_receipts directement (aucune policy
// d'écriture), et c'est voulu — l'horodatage doit être celui du serveur et
// une preuve écrite ne doit plus pouvoir bouger.
//
// Ce que cette classe NE fait jamais :
//   • proposer la galerie. Les photos de preuve sont prises dans l'app, à
//     l'instant de la remise. Une photo choisie dans la pellicule ne prouve
//     rien, elle peut dater de n'importe quand.
//   • lire le code de livraison. La table qui le porte n'a aucune policy pour
//     le livreur : elle n'existe pas pour lui. Le code saisi part au serveur,
//     qui seul sait s'il est bon.

import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/permissions/location_disclosure.dart';

/// Version envoyée au serveur à chaque étape, pour mesurer l'adoption du
/// nouveau flux pendant le déploiement souple. Une constante et non
/// package_info_plus : seules les versions qui appellent ces RPC comptent,
/// donc distinguer les builds récents entre eux suffit. À bumper à chaque
/// release.
const String kDriverAppVersion = '1.1.0';

/// Nombre de codes erronés tolérés avant blocage. Doit rester aligné avec la
/// limite appliquée côté serveur dans colis_verify_and_deliver.
const int kColisMaxCodeAttempts = 5;

class ColisProofRepository {
  ColisProofRepository(this._supabase);

  final SupabaseClient _supabase;

  static const _bucket = 'colis-proofs';

  /// Le reçu, ou null si la commande n'est pas un colis (ou si la migration
  /// n'a pas encore été appliquée — l'app doit continuer de fonctionner).
  Future<Map<String, dynamic>?> loadReceipt(String orderId) async {
    try {
      final row = await _supabase
          .from('colis_receipts')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();
      return row;
    } catch (_) {
      // Table absente = migration pas encore passée. On ne bloque pas le
      // livreur pour ça : le flux historique reste utilisable.
      return null;
    }
  }

  /// Photo prise dans l'app, jamais choisie dans la pellicule.
  Future<File?> capturePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    return picked == null ? null : File(picked.path);
  }

  /// Position courante, ou null si elle est refusée ou indisponible. Le GPS
  /// ne bloque pas la remise : une preuve photo sans position vaut mieux que
  /// pas de preuve du tout, et le serveur enregistre l'absence telle quelle.
  Future<Position?> currentPosition() async {
    try {
      final perm = await LocationDisclosure.requestIfAccepted();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
    } catch (_) {
      return null;
    }
  }

  /// Dépose une preuve et renvoie son chemin.
  ///
  /// Chemin `<order_id>/<étape>_<horodatage>.jpg`. L'identifiant de commande
  /// reste le premier segment, c'est lui que lisent les policies du bucket.
  ///
  /// L'horodatage n'est pas décoratif : sans lui, un code erroné laissait une
  /// photo à `<order_id>/delivery.jpg`, et la tentative suivante se heurtait
  /// au refus de doublon du stockage — le livreur restait bloqué sur « l'envoi
  /// de la photo a échoué », définitivement.
  ///
  /// Et surtout PAS d'upsert : il permettrait de remplacer une preuve déjà
  /// enregistrée, ce qui ruinerait l'immuabilité que toute la migration
  /// s'emploie à garantir. Seul le chemin transmis à une RPC qui réussit est
  /// retenu dans le reçu ; les autres restent des fichiers orphelins, sans
  /// valeur probante puisque aucun reçu ne les référence.
  Future<String> uploadProof({
    required String orderId,
    required String step,
    required File photo,
  }) async {
    final path = '$orderId/${step}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          await photo.readAsBytes(),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return path;
  }

  /// Prise en charge. Lève une [PostgrestException] dont le message est
  /// destiné au livreur tel quel (les RPC parlent français).
  ///
  /// [photoPath] vient de [uploadProof] : l'appelant dépose la photo une fois
  /// et réutilise le chemin si la RPC doit être rejouée.
  Future<void> recordPickup({
    required String orderId,
    required String photoPath,
  }) async {
    final pos = await currentPosition();
    await _supabase.rpc('colis_record_pickup', params: {
      'p_order_id': orderId,
      'p_photo_path': photoPath,
      'p_lat': pos?.latitude,
      'p_lng': pos?.longitude,
      'p_app_version': kDriverAppVersion,
    });
  }

  /// Remise. [code] est ignoré en mode sans code ; c'est le serveur qui
  /// tranche, l'app ne fait que transmettre.
  Future<void> verifyAndDeliver({
    required String orderId,
    required String photoPath,
    String? code,
  }) async {
    final pos = await currentPosition();
    await _supabase.rpc('colis_verify_and_deliver', params: {
      'p_order_id': orderId,
      'p_code': code,
      'p_photo_path': photoPath,
      'p_lat': pos?.latitude,
      'p_lng': pos?.longitude,
      'p_app_version': kDriverAppVersion,
    });
  }

  /// URL signée pour réafficher une preuve déjà déposée. Le bucket est privé :
  /// getPublicUrl ne donnerait rien.
  Future<String?> signedProofUrl(String path, {int secondsValid = 3600}) async {
    try {
      return await _supabase.storage
          .from(_bucket)
          .createSignedUrl(path, secondsValid);
    } catch (_) {
      return null;
    }
  }
}
