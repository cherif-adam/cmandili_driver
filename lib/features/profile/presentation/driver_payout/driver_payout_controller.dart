import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/providers/driver_online_provider.dart';

/// One controller per payout screen on display (the argument is a key the
/// screen creates for itself), auto-disposed with it. The balance comes from
/// driverWalletProvider, the deductions from driverDeliveryHistoryProvider.
/// Drivers are paid in cash: there are no bank details to load or save, so
/// the online switch is the only action left.
final driverPayoutControllerProvider = NotifierProvider.autoDispose
    .family<DriverPayoutController, void, Object>(DriverPayoutController.new);

class DriverPayoutController extends AutoDisposeFamilyNotifier<void, Object> {
  @override
  void build(Object screenKey) {}

  // ── User actions ──────────────────────────────────────────────────────────

  /// The online switch, unchanged: driverOnlineProvider does the work.
  void setOnline(bool next) => ref.read(driverOnlineProvider.notifier).setOnline(next);
}
