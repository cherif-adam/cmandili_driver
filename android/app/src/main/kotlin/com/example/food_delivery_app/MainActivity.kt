package com.cmandili.driver

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity — Driver App
 *
 * Bridges the native delivery-offer notification tap (built by
 * CmandiliMessagingService when the app is killed) into Dart so the app can
 * surface the accept/reject offer dialog for the tapped order.
 *
 * When the app is terminated, the alarm notification is built natively and its
 * tap PendingIntent launches THIS activity with `order_id` / `notification_type`
 * extras. FirebaseMessaging.getInitialMessage() is NULL on this path (no FCM
 * message object is reconstructed), so Dart must read these intent extras over
 * the MethodChannel below instead.
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.cmandili.driver/notifications"
    }

    private var channel: MethodChannel? = null

    // Holds the order_id from the launch intent until Dart asks for it via
    // getInitialNotification(). Consumed once so a hot restart doesn't re-trigger.
    private var pendingOrderId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingOrderId = orderIdFrom(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                // Cold-start path: Dart calls this after the engine is ready to
                // see if the app was launched by tapping an offer notification.
                "getInitialNotification" -> {
                    result.success(pendingOrderId)
                    pendingOrderId = null // consume — only surface the offer once
                }
                "getManufacturer" -> result.success(Build.MANUFACTURER)
                "openAutoStartSettings" -> result.success(openAutoStartSettings())
                else -> result.notImplemented()
            }
        }
    }

    // Warm path: app already running in background, driver taps the notification.
    // Android delivers the tap via onNewIntent (singleTop launch mode), so push
    // the order_id straight to Dart instead of stashing it for a cold start.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val orderId = orderIdFrom(intent)
        if (orderId != null) {
            channel?.invokeMethod("onNotificationTap", orderId)
        }
    }

    private fun orderIdFrom(intent: Intent?): String? {
        if (intent?.getStringExtra("notification_type") != "offer_to_driver") return null
        val orderId = intent.getStringExtra("order_id")
        return if (orderId.isNullOrBlank()) null else orderId
    }

    /**
     * MIUI keeps a separate "Autostart" toggle outside the standard Android
     * battery-optimization API — Permission.ignoreBatteryOptimizations (already
     * requested in push_service.dart) only covers stock Doze. Without Autostart
     * granted, MIUI can cancel the FCM wake broadcast before it ever reaches
     * CmandiliMessagingService, which is what makes delivery-offer alarms
     * arrive minutes late (observed live: ~2 min) or not at all on Xiaomi
     * devices. There's no public API for this — AutoStartManagementActivity is
     * the component every major app (WhatsApp, Telegram, etc.) targets for it
     * and has been stable across MIUI releases, but we still fall back to the
     * app's own settings page if it doesn't resolve (non-MIUI Xiaomi builds, or
     * a future MIUI version that renamed it). Returns true if the MIUI-specific
     * screen was reached, false if we fell back to generic app settings.
     */
    private fun openAutoStartSettings(): Boolean {
        try {
            startActivity(Intent().apply {
                component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity",
                )
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })
            return true
        } catch (_: Exception) {
            // Not MIUI, or a version that renamed/removed this activity.
        }
        return try {
            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })
            false
        } catch (_: Exception) {
            false
        }
    }
}
