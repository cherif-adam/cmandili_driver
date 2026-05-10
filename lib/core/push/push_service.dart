import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Channel id must match com.google.firebase.messaging.default_notification_channel_id
// in AndroidManifest.xml so background `notification` payloads land here too.
const String _kAndroidChannelId   = 'cmandili_orders';
const String _kAndroidChannelName = 'Order updates';
const String _kAndroidChannelDesc = 'New deliveries and order updates';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Android renders `notification`-payload pushes automatically using the
  // default channel from the manifest, so nothing to do here.
}

/// Single 10-second offer pushed by the backend to one driver at a time.
/// The home screen watches [PushService.instance.offerStream] and shows a
/// modal countdown when one fires.
class OrderOffer {
  final String orderId;
  final DateTime receivedAt;
  const OrderOffer({required this.orderId, required this.receivedAt});
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final _offerController = StreamController<OrderOffer>.broadcast();

  /// Emits when an FCM with `event=offer_to_driver` lands while the app is
  /// in the foreground. Background/terminated pushes still wake the app via
  /// the system notification; the home screen re-checks the orders table on
  /// resume and shows the modal if an offer is still active.
  Stream<OrderOffer> get offerStream => _offerController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Pre-create the Android channel so the OS has it ready when background
    // pushes arrive. Without this the first push after install is silently
    // dropped on Android 8+.
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _kAndroidChannelId,
          _kAndroidChannelName,
          description: _kAndroidChannelDesc,
          importance: Importance.high,
        ));

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _registerToken();
    _fcm.onTokenRefresh.listen((_) => _registerToken());

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _registerToken();
      }
    });
  }

  Future<void> _registerToken() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final token = await _fcm.getToken();
    if (token == null) return;
    try {
      await Supabase.instance.client.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': defaultTargetPlatform.name,
      }, onConflict: 'token');
    } catch (_) {}
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Route 10s offers into the offerStream so the home screen can show a
    // modal countdown. Skip the local-notification banner for offers — the
    // modal is the user-facing surface and a duplicate banner is noisy.
    final event = message.data['event'] as String?;
    if (event == 'offer_to_driver') {
      final orderId = message.data['order_id'] as String?;
      if (orderId != null && orderId.isNotEmpty) {
        _offerController.add(OrderOffer(
          orderId: orderId,
          receivedAt: DateTime.now(),
        ));
        return;
      }
    }

    final title = message.notification?.title ?? message.data['title'] as String?;
    final body  = message.notification?.body  ?? message.data['body']  as String?;
    if (title == null && body == null) return;
    _local.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kAndroidChannelId,
          _kAndroidChannelName,
          channelDescription: _kAndroidChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
