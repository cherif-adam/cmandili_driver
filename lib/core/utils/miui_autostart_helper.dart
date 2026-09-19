import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MIUI (Xiaomi) keeps its "Autostart" toggle outside the standard Android
/// battery-optimization API — Permission.ignoreBatteryOptimizations (already
/// requested in PushService.initialize) only covers stock Doze. Without
/// Autostart granted, MIUI can cancel the FCM wake broadcast before it ever
/// reaches CmandiliMessagingService, which is what makes delivery-offer
/// alarms arrive minutes late or not at all on Xiaomi devices. There's no
/// public API to check or request it — only a best-effort deep link to
/// MIUI's own settings screen (see MainActivity.openAutoStartSettings), so
/// this surfaces a one-time prompt explaining why and pointing the driver
/// there.
class MiuiAutostartHelper {
  MiuiAutostartHelper._();

  static const _channel = MethodChannel('com.cmandili.driver/notifications');
  static const _prefsKey = 'miui_autostart_prompted';

  static Future<bool> _isXiaomi() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final manufacturer = await _channel.invokeMethod<String>('getManufacturer');
      return (manufacturer ?? '').toLowerCase() == 'xiaomi';
    } catch (_) {
      return false;
    }
  }

  /// Call once after the driver reaches the home screen. Returns false (skip
  /// showing anything) if this isn't a Xiaomi device or the prompt already
  /// ran before — persisted so it never nags on every app launch.
  static Future<bool> shouldPrompt() async {
    if (!await _isXiaomi()) return false;
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefsKey) ?? false);
  }

  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openAutoStartSettings');
    } catch (_) {}
  }
}
