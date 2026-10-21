import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/providers/driver_orders_provider.dart';
import '../../providers/earnings_provider.dart';

/// The earnings tab's logic. Its state is the period shown ('today',
/// 'week' or 'month'); the figures come from earningsProvider and the list
/// from driverDeliveryHistoryProvider. Kept alive by the screen watching it.
final earningsControllerProvider =
    NotifierProvider.autoDispose<EarningsController, String>(EarningsController.new);

class EarningsController extends AutoDisposeNotifier<String> {
  @override
  String build() {
    // A delivery just ended (or began): the totals and the history change at
    // that moment, not when the driver next switches tabs. Without this they
    // only refreshed on becoming the active tab or on pull-to-refresh.
    ref.listen(activeDeliveryProvider, (_, __) => refresh());
    return 'today';
  }

  // ── User actions ──────────────────────────────────────────────────────────

  void selectPeriod(String period) => state = period;

  /// Reads the figures (every period) and the history again.
  void refresh() {
    ref.invalidate(earningsProvider);
    ref.invalidate(driverDeliveryHistoryProvider);
  }

  void retryEarnings() => ref.invalidate(earningsProvider(state));

  void retryHistory() => ref.invalidate(driverDeliveryHistoryProvider);
}
