// Vérification du livreur : CIN + contrat signé et légalisé.
//
// L'app ne décide rien : elle demande au serveur, qui seul connaît le dossier
// (driver_identity est admin-only, le livreur ne voit même pas la table) et
// l'état du durcissement.
//
// Ce que l'écran en tire est du CONFORT. Le refus réel est côté base : le
// garde-fou de colonnes sur `drivers` refuse le passage en ligne, et les trois
// portes d'éligibilité écartent le livreur du dispatch et de l'acceptation.
// Un APK antérieur, qui n'affiche pas l'écran d'attente, est donc bloqué quand
// même — c'est le point de toute la conception.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'driver_orders_provider.dart' show currentDriverIdProvider;

/// Vrai quand le livreur peut travailler.
///
/// Renvoie `true` en cas d'erreur ou de fonction absente : tant que la
/// migration n'est pas appliquée, l'app doit se comporter comme avant. Un
/// faux négatif ici bloquerait un livreur légitime sur un écran d'attente
/// alors que le serveur, lui, le laisse travailler.
final driverIsVerifiedProvider = FutureProvider<bool>((ref) async {
  final driverId = await ref.watch(currentDriverIdProvider.future);
  if (driverId == null) return true;

  try {
    final res = await Supabase.instance.client
        .rpc('driver_is_verified', params: {'p_driver_id': driverId});
    return res == true;
  } catch (_) {
    return true;
  }
});
