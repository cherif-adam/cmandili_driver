import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/providers/driver_online_provider.dart';
import '../../../orders/providers/driver_orders_provider.dart';
import '../../providers/driver_wallet_provider.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import 'driver_payout_controller.dart';
import 'widgets/deduction_history.dart';
import 'widgets/prepaid_balance_card.dart';

/// Earnings & status: the prepaid balance, what moved it, then the online
/// switch. UI only: the switch goes through [DriverPayoutController].
class DriverPayoutScreen extends ConsumerStatefulWidget {
  const DriverPayoutScreen({super.key});

  @override
  ConsumerState<DriverPayoutScreen> createState() => _DriverPayoutScreenState();
}

class _DriverPayoutScreenState extends ConsumerState<DriverPayoutScreen> {
  /// This screen's own controller (see [driverPayoutControllerProvider]).
  late final _provider = driverPayoutControllerProvider(Object());

  DriverPayoutController get _controller => ref.read(_provider.notifier);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    final isOnline = ref.watch(driverOnlineProvider);
    final walletAsync = ref.watch(driverWalletProvider);
    final historyAsync = ref.watch(driverDeliveryHistoryProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.earningsAndStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Prepaid balance card + low-balance banner
            walletAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (balance) => PrepaidBalanceCard(balance: balance),
            ),
            const SizedBox(height: 20),

            // Deduction history — explains what's been moving the
            // balance above, so it sits right next to it.
            DeductionHistorySection(historyAsync: historyAsync),
            const SizedBox(height: 20),

            // Online/Offline toggle
            _OnlineToggle(isOnline: isOnline, onChanged: (next) => _controller.setOnline(next)),
          ],
        ),
      ),
    );
  }
}

// ── Sections, in screen order ────────────────────────────────────────────────

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.isOnline, required this.onChanged});

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? l.youAreOnline : l.youAreOffline,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  isOnline ? l.canReceiveOrders : l.turnOnToReceive,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            activeColor: Colors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
