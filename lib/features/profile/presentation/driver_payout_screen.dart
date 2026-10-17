import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/driver_online_provider.dart';
import '../../orders/providers/driver_orders_provider.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import 'dart:async';

/// Prepaid wallet balance for the signed-in driver. Balance <= 0 means the
/// account is blocked from receiving new orders until the admin tops it up.
///
/// LIVE. This used to be read once: the dashboard that shows it stays mounted
/// for the whole session, so the balance a driver saw was the one from when
/// they logged in, however many deliveries they had completed since. It is
/// now re-read:
///   * the moment their active delivery changes (accepted, picked up,
///     delivered, cancelled);
///   * every 15 s while the app is on screen;
///   * when the app comes back to the front (see HomeScreen).
final driverWalletProvider = StreamProvider.autoDispose<double?>((ref) {
  final controller = StreamController<double?>();
  Timer? settle;
  var closed = false;

  Future<void> refresh() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (!closed) controller.add(null);
      return;
    }
    try {
      final row = await Supabase.instance.client
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .maybeSingle();
      if (!closed) controller.add((row?['balance'] as num?)?.toDouble());
    } catch (e) {
      // Offline etc: keep showing the last known balance; the next trigger
      // tries again. An error state would blank the card.
      debugPrint('wallet refresh failed: $e');
    }
  }

  refresh();

  // The moment an order changes. The server writes the commission and the
  // new balance in the same transaction that marks an order delivered, so by
  // the time the order event arrives the wallet is already up to date. One
  // more read two seconds later covers anything the server settles after.
  ref.listen(activeDeliveryProvider, (_, __) {
    refresh();
    settle?.cancel();
    settle = Timer(const Duration(seconds: 2), refresh);
  });

  // Safety net, and what picks up changes that are not tied to an order (an
  // admin top-up): `wallets` is not in the realtime publication, so nothing
  // announces those. Only while the app is on screen.
  final poll = Timer.periodic(const Duration(seconds: 15), (_) {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      refresh();
    }
  });

  ref.onDispose(() {
    closed = true;
    poll.cancel();
    settle?.cancel();
    controller.close();
  });
  return controller.stream;
});

class DriverPayoutScreen extends ConsumerStatefulWidget {
  const DriverPayoutScreen({super.key});

  @override
  ConsumerState<DriverPayoutScreen> createState() => _DriverPayoutScreenState();
}

class _DriverPayoutScreenState extends ConsumerState<DriverPayoutScreen> {
  @override
  Widget build(BuildContext context) {
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
                    data: (balance) => _PrepaidBalanceCard(balance: balance),
                  ),
                  const SizedBox(height: 20),

                  // Deduction history — explains what's been moving the
                  // balance above, so it sits right next to it.
                  _DeductionHistorySection(historyAsync: historyAsync),
                  const SizedBox(height: 20),

                  // Online/Offline toggle
                  Container(
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
                          onChanged: (next) => ref.read(driverOnlineProvider.notifier).setOnline(next),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Prepaid balance summary. When the balance is at or below zero the driver is
/// blocked from receiving orders, so we show a prominent red recharge banner.
class _PrepaidBalanceCard extends StatelessWidget {
  final double? balance;

  const _PrepaidBalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final value = balance ?? 0;
    final isBlocked = value <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text('Solde prépayé',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${value.toStringAsFixed(3)} DT',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (isBlocked) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre solde est épuisé. Rechargez votre solde pour '
                    'recevoir de nouvelles commandes.',
                    style: TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// "Why is my balance moving" — recent commission deductions (and loyalty
/// subsidies, when they apply), pulled from the same settlements-derived
/// data the Earnings screen's per-delivery breakdown uses, so the two stay
/// consistent with each other. Capped at 10 rows; not a full transaction
/// history, just enough to explain recent balance changes at a glance.
class _DeductionHistorySection extends StatelessWidget {
  final AsyncValue<List<Order>> historyAsync;
  const _DeductionHistorySection({required this.historyAsync});

  @override
  Widget build(BuildContext context) {
    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (orders) {
        final deductions = orders
            .where((o) => o.commissionAmount != null)
            .take(10)
            .toList();
        if (deductions.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historique des déductions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              const Text(
                'D\'où vient la baisse de votre solde, commande par commande.',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              for (final order in deductions) ...[
                _DeductionRow(order: order),
                if (order != deductions.last) ...[
                  const SizedBox(height: 10),
                  Container(height: 1, color: AppColors.background),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DeductionRow extends StatelessWidget {
  final Order order;
  const _DeductionRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final commission = order.commissionAmount!;
    final subsidy = order.loyaltySubsidyAmount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commande #${order.id.substring(0, 8).toUpperCase()}',
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          'Collecté: ${order.deliveryFee.toStringAsFixed(3)} DT — '
          'Commission déduite: ${commission.toStringAsFixed(3)} DT',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        if (subsidy != null) ...[
          const SizedBox(height: 2),
          Text(
            'Subvention fidélité créditée: +${subsidy.toStringAsFixed(3)} DT',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}
