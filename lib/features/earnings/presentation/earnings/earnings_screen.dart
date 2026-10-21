import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/data/models/order.dart';
import '../../../orders/providers/driver_orders_provider.dart';
import '../../providers/earnings_provider.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import 'earnings_controller.dart';
import 'widgets/delivery_card.dart';

/// The earnings tab: period, total for it, then the recent deliveries.
/// UI only: the period and the refreshes live in [EarningsController].
class EarningsScreen extends ConsumerStatefulWidget {
  // HomeScreen keeps every tab mounted via IndexedStack, so this screen
  // never gets a fresh initState when the driver switches to it — isActive
  // is how it finds out instead (see didUpdateWidget below).
  final bool isActive;

  const EarningsScreen({super.key, this.isActive = true});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  EarningsController get _controller => ref.read(earningsControllerProvider.notifier);

  @override
  void didUpdateWidget(covariant EarningsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Becoming the active tab is the only signal available — refetch so
      // a delivery completed on another tab isn't shown stale here.
      _controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(earningsControllerProvider);
    final earningsAsync = ref.watch(earningsProvider(period));
    final historyAsync = ref.watch(driverDeliveryHistoryProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.earnings,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => _controller.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Period selector
            _PeriodSelector(selected: period, onSelect: (v) => _controller.selectPeriod(v)),

            const SizedBox(height: 20),

            // Earnings card
            _EarningsCard(earningsAsync: earningsAsync, onRetry: () => _controller.retryEarnings()),

            const SizedBox(height: 24),

            // Recent deliveries
            Text(l.recentDeliveries,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _DeliveryHistory(historyAsync: historyAsync, onRetry: () => _controller.retryHistory()),
          ],
        ),
      ),
    );
  }
}

// ── Sections, in screen order ────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelect});

  final String selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          _PeriodTab(label: l.today, value: 'today', selected: selected, onTap: onSelect),
          _PeriodTab(label: l.thisWeek, value: 'week', selected: selected, onTap: onSelect),
          _PeriodTab(label: l.thisMonth, value: 'month', selected: selected, onTap: onSelect),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.earningsAsync, required this.onRetry});

  final AsyncValue<Map<String, dynamic>> earningsAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return earningsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 36),
            const SizedBox(height: 8),
            Text(l.couldNotLoadEarnings),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l.retry),
            ),
          ],
        ),
      ),
      data: (data) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.totalEarnings,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              '${(data['total'] as double).toStringAsFixed(2)} DT',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.delivery_dining,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${data['count']} ${l.deliveriesCompleted}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryHistory extends StatelessWidget {
  const _DeliveryHistory({required this.historyAsync, required this.onRetry});

  final AsyncValue<List<Order>> historyAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 36),
            const SizedBox(height: 8),
            Text(l.couldNotLoadHistory),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l.retry),
            ),
          ],
        ),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.receipt_long,
                      size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(l.noDeliveriesYet,
                      style: const TextStyle(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }
        return Column(
          children: orders.take(20).map((order) => DeliveryCard(order: order)).toList(),
        );
      },
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;

  const _PeriodTab(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
