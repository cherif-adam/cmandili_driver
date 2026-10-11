import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  Timer? _heartbeat;

  /// True while the switch is being applied (GPS fix, database write, service
  /// start). reconcile() must stay out of the way during that time: it used
  /// to read the row before the "online" write had landed -- any dialog that
  /// closed in between (location permission, GPS prompt) fires a resume --
  /// and concluded the driver was offline, undoing the switch they had just
  /// flipped.
  bool _switching = false;

  DriverOnlineNotifier(this._ref) : super(false) {
    reconcile();
  }

  @override
  void dispose() {
    _offlineRetry?.cancel();
    _heartbeat?.cancel();
    super.dispose();
  }

  /// Brings the switch, the driver's saved choice and `drivers.is_online`
  /// back in line. Runs at start-up and whenever the app comes to the front.
  ///
  /// The driver's own choice decides; the database is corrected to match it.
  ///
  ///  * chose ONLINE  -> online. If the database says otherwise (the server
  ///    may switch off a driver whose phone has been silent -- see
  ///    drivers_auto_offline_stale -- or a write was lost), go back online:
  ///    the driver never asked to stop, and a driver shown "online" who gets
  ///    no orders has no way to know why. Also makes sure the background
  ///    service is running.
  ///  * chose OFFLINE -> offline. If the database still says online, the
  ///    "go offline" write was lost (no network at that moment, a logout that
  ///    never told the server): write it again.
  ///  * no recorded choice (first run after this update) -> the database is
  ///    taken at its word.
  Future<void> reconcile() async {
    if (_switching) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final row = await Supabase.instance.client
          .from('drivers')
          .select('id, is_online')
          .eq('user_id', userId)
          .maybeSingle();
      if (!mounted || row == null || _switching) return;
      final dbOnline = row['is_online'] as bool? ?? false;
      final driverId = row['id'] as String;
      final prefs = await SharedPreferences.getInstance();
      final wantsOnline = prefs.getBool(kDriverWantsOnlineKey) ?? dbOnline;
      await prefs.setBool(kDriverWantsOnlineKey, wantsOnline);

      if (!wantsOnline) {
        if (mounted) state = false;
        _stopHeartbeat();
        if (dbOnline) await _writeOffline();
        return;
      }

      if (mounted) state = true;
      // Says "online, seen just now" -- which is also what puts a driver the
      // server had switched off back in the pool.
      await _beat();
      _startHeartbeat();
      await BackgroundLocationService.ensureRunning(driverId: driverId);
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
    if (state == next || _switching) return;
    final driverId = await _ref.read(currentDriverIdProvider.future);
    if (driverId == null) return;
    _switching = true;
    try {
      state = next;
      _offlineRetry?.cancel();

      // Recorded first: even if everything below fails, the phone knows what
      // the driver asked for and reconcile() can finish the job later.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDriverWantsOnlineKey, next);

      if (!next) {
        _stopHeartbeat();
        // Stop the service first so nothing keeps the driver looking active,
        // then tell the server (retried until it is confirmed).
        if (await BackgroundLocationService.isRunning) {
          await BackgroundLocationService.stopTracking();
        }
        await _writeOffline();
        return;
      }

      final Map<String, dynamic> payload = {
        'is_online': true,
        // Always, position or not: this is the "seen just now" the server
        // looks at. It used to be written only with a GPS fix, so a driver
        // who went online indoors started out already looking stale.
        'last_location_update': DateTime.now().toUtc().toIso8601String(),
      };
      debugPrint('[Online] Fetching GPS position...');
      final position = await LocationService.getCurrentPosition();
      debugPrint('[Online] Position result: $position');
      if (position != null) {
        debugPrint('[Online] lat=${position.latitude}, lng=${position.longitude}');
        payload['current_lat'] = position.latitude;
        payload['current_lng'] = position.longitude;
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
        // UPDATE policy exactly. Filtering by drivers.id alone can silently
        // affect 0 rows if RLS blocks the row (Supabase returns 200 with no
        // error).
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

      _startHeartbeat();
      await BackgroundLocationService.startOnlinePresence(driverId: driverId);
    } finally {
      _switching = false;
    }
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────

  /// While the driver is online, tell the server so every two minutes.
  ///
  /// `last_location_update` is how the server (and the admin map) tells a
  /// working driver from a phone that went dark. It was only refreshed by
  /// the background service -- on a GPS movement, or on a heartbeat that did
  /// nothing when the phone had no stored position -- and that service stops
  /// when location permission is missing or the phone maker kills it. A
  /// driver sitting in the open app was then switched off by the server
  /// after 15 minutes and stopped receiving orders, with the switch still
  /// showing online. The app now vouches for itself.
  void _startHeartbeat() {
    _heartbeat ??= Timer.periodic(const Duration(minutes: 2), (_) {
      if (mounted && state && !_switching) _beat();
    });
  }

  void _stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  Future<void> _beat() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final payload = <String, dynamic>{
      'is_online': true,
      'last_location_update': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      // The position the phone already has: no new GPS fix, no battery cost,
      // no permission prompt.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        payload['current_lat'] = last.latitude;
        payload['current_lng'] = last.longitude;
      }
    } catch (_) {
      // No permission / no provider: the timestamp alone still counts.
    }
    try {
      await Supabase.instance.client
          .from('drivers')
          .update(payload)
          .eq('user_id', uid);
    } catch (e) {
      debugPrint('[Online] heartbeat failed: $e'); // offline: next beat
    }
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
