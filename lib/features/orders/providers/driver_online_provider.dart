import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/background_location_service.dart';
import '../../../core/utils/location_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'driver_orders_provider.dart';

/// What the driver last chose with the online/offline switch, kept on the
/// phone. The server decides who gets an order from `drivers.is_online`; this
/// is the driver's side of that agreement, so the two can be compared and the
/// database corrected when they drift apart. Also read natively by
/// CmandiliMessagingService and by the Dart background handler, so an offer
/// that slips through while the driver is offline does not ring.
const String kDriverWantsOnlineKey = 'driver_wants_online';

/// Public state for the driver's online/offline toggle. Reads the current
/// `drivers.is_online` row on init and persists toggles back to Supabase.
/// Also starts/stops the foreground location service so push + GPS keep
/// working while the driver is online and the app is backgrounded.
final driverOnlineProvider =
    StateNotifierProvider<DriverOnlineNotifier, bool>((ref) {
  // Rebuilt when the signed-in account changes. The notifier used to live
  // for the whole app run: after a logout/login it kept showing the previous
  // account's switch position, whatever the new account's row said.
  ref.watch(authStateProvider.select((a) => a.valueOrNull?.uid));
  return DriverOnlineNotifier(ref);
});

class DriverOnlineNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _offlineRetry;

  DriverOnlineNotifier(this._ref) : super(false) {
    reconcile();
  }

  @override
  void dispose() {
    _offlineRetry?.cancel();
    super.dispose();
  }

  /// Brings the switch, the driver's saved choice and `drivers.is_online`
  /// back in line. Runs at start-up and whenever the app comes to the front.
  ///
  ///  * database says OFFLINE          -> offline everywhere (it wins: an
  ///    order must never go to someone the database stopped counting on).
  ///  * database ONLINE, driver chose offline -> the "go offline" write was
  ///    lost (no network at that moment, or a logout that never told the
  ///    server). Write it again. This was how a driver who had switched off
  ///    kept receiving orders.
  ///  * database ONLINE, driver chose online  -> online; make sure the
  ///    background service is really running, so the position stays fresh
  ///    (it is stopped by a reboot, a force-stop, or the end of a delivery).
  Future<void> reconcile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final row = await Supabase.instance.client
          .from('drivers')
          .select('id, is_online')
          .eq('user_id', userId)
          .maybeSingle();
      if (!mounted || row == null) return;
      final dbOnline = row['is_online'] as bool? ?? false;
      final prefs = await SharedPreferences.getInstance();
      // Null on the first run after this update: no recorded choice yet, so
      // the database is taken at its word.
      final wantsOnline = prefs.getBool(kDriverWantsOnlineKey);

      if (!dbOnline) {
        await prefs.setBool(kDriverWantsOnlineKey, false);
        if (mounted) state = false;
        return;
      }

      if (wantsOnline == false) {
        if (mounted) state = false;
        await _writeOffline();
        return;
      }

      await prefs.setBool(kDriverWantsOnlineKey, true);
      if (mounted) state = true;
      await BackgroundLocationService.ensureRunning(
        driverId: row['id'] as String,
      );
    } catch (e) {
      // Offline at launch etc. The switch keeps its last value; tried again
      // on the next resume.
      debugPrint('[Online] reconcile failed: $e');
    }
  }

  /// Renseigne quand le passage en ligne a reussi cote base mais sans
  /// position (GPS coupe, permission refusee). L'ecran l'affiche puis le
  /// remet a null. Volontairement separe de `state`, qui reste un simple
  /// booleen en ligne / hors ligne.
  String? lastError;

  Future<void> setOnline(bool next) async {
    lastError = null;
    if (state == next) return;
    final driverId = await _ref.read(currentDriverIdProvider.future);
    if (driverId == null) return;
    state = next;
    _offlineRetry?.cancel();

    // Recorded first: even if everything below fails, the phone knows what
    // the driver asked for and reconcile() can finish the job later.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kDriverWantsOnlineKey, next);

    if (!next) {
      // Stop the service first so nothing keeps the driver looking active,
      // then tell the server (retried until it is confirmed).
      if (await BackgroundLocationService.isRunning) {
        await BackgroundLocationService.stopTracking();
      }
      await _writeOffline();
      return;
    }

    final Map<String, dynamic> payload = {'is_online': true};
    debugPrint('[Online] Fetching GPS position...');
    final position = await LocationService.getCurrentPosition();
    debugPrint('[Online] Position result: $position');
    if (position != null) {
      debugPrint('[Online] lat=${position.latitude}, lng=${position.longitude}');
      payload['current_lat'] = position.latitude;
      payload['current_lng'] = position.longitude;
      // .toUtc() — see background_location_service.dart. This is the path
      // that runs when the driver flips themselves online, so without it a
      // driver appeared online with a timestamp an hour in the future from
      // the very first write.
      payload['last_location_update'] =
          DateTime.now().toUtc().toIso8601String();
    } else {
      debugPrint('[Online] ⚠️ Position is NULL — coordinates will NOT be updated');
      // Sans coordonnees, la carte admin ne peut rien dessiner : le livreur
      // se croit en ligne et reste invisible du dispatch. Il faut le lui
      // dire, pas seulement l'ecrire dans les logs.
      lastError = await LocationService.isLocationServiceEnabled()
          ? "Autorisation de localisation refusee. Activez-la dans les "
              "parametres pour apparaitre sur la carte."
          : "Le GPS est desactive. Activez la localisation pour passer en "
              "ligne.";
    }

    final authUid = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('[Online] driverId (drivers.id)=$driverId  auth.uid()=$authUid');
    debugPrint('[Online] Supabase payload: $payload');
    try {
      // Filter by user_id = auth.uid() so the WHERE clause matches the RLS
      // UPDATE policy exactly. Filtering by drivers.id alone can silently affect
      // 0 rows if RLS blocks the row (Supabase returns 200 with no error).
      final updated = await Supabase.instance.client
          .from('drivers')
          .update(payload)
          .eq('user_id', authUid!)
          .select('id, current_lat, current_lng');
      if ((updated as List).isEmpty) {
        debugPrint('[Online] ⚠️ UPDATE affected 0 rows — RLS may be blocking or user_id mismatch');
      } else {
        debugPrint('[Online] Supabase update SUCCESS → $updated');
      }
    } catch (e) {
      debugPrint('[Online] ❌ Supabase update FAILED: $e');
    }

    await BackgroundLocationService.startOnlinePresence(driverId: driverId);
  }

  /// Tells the server this driver is offline, and keeps trying until it is
  /// confirmed. A failure here used to be only a log line: the switch showed
  /// offline, the database still said online, and orders kept coming.
  Future<void> _writeOffline() async {
    _offlineRetry?.cancel();
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final updated = await Supabase.instance.client
          .from('drivers')
          .update({'is_online': false})
          .eq('user_id', uid)
          .select('id');
      if ((updated as List).isNotEmpty) {
        debugPrint('[Online] offline confirmed by the server');
        return;
      }
      debugPrint('[Online] ⚠️ offline write matched 0 rows');
    } catch (e) {
      debugPrint('[Online] ❌ offline write failed, will retry: $e');
    }
    if (!mounted) return;
    _offlineRetry = Timer(const Duration(seconds: 15), () {
      // The driver may have gone back online in the meantime.
      if (mounted && !state) _writeOffline();
    });
  }

  Future<void> toggle() => setOnline(!state);
}
