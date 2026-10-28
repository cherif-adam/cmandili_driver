import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_disclosure_screen.dart';

/// Google Play wants the driver to read, in the app and before Android's
/// location prompt, what the location is used for, and to agree to it.
///
/// Every location request of the app goes through [requestIfAccepted], which
/// never shows Android's prompt before the explanation was accepted. The
/// screens that start a location flow (the home map, the online switch) call
/// [ensure] first, which shows the explanation when the prompt is still to
/// come.
///
/// Only "while using the app" is asked: the GPS runs in a foreground service
/// of type location, started from the open app (going online, accepting an
/// order, reopening the app), and Android keeps delivering positions to it in
/// the background with that permission. "All the time" is not needed.
class LocationDisclosure {
  static const _acceptedKey = 'location_disclosure_accepted_v1';

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_acceptedKey) ?? false;
  }

  static bool _granted(LocationPermission p) =>
      p == LocationPermission.whileInUse || p == LocationPermission.always;

  /// True when the location flow may go on: permission already granted, or
  /// the explanation accepted now or earlier. False when the driver chose
  /// "Not now" (nothing is asked to Android then).
  static Future<bool> ensure(BuildContext context) async {
    if (_granted(await Geolocator.checkPermission())) return true;
    if (await isAccepted()) return true;
    if (!context.mounted) return false;
    final accepted = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const LocationDisclosureScreen(),
          ),
        ) ??
        false;
    if (accepted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_acceptedKey, true);
    }
    return accepted;
  }

  /// The only call to Android's location prompt in the app. Before the
  /// explanation was accepted it returns the current permission (denied)
  /// without prompting.
  static Future<LocationPermission> requestIfAccepted() async {
    final current = await Geolocator.checkPermission();
    if (current != LocationPermission.denied) return current;
    if (!await isAccepted()) return current;
    return Geolocator.requestPermission();
  }
}
