import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../orders/data/models/order.dart';

/// "Why is my balance moving" — recent commission deductions (and loyalty
/// subsidies, when they apply), pulled from the same settlements-derived
/// data the Earnings screen's per-delivery breakdown uses, so the two stay
/// consistent with each other. Capped at 10 rows; not a full transaction
/// history, just enough to explain recent balance changes at a glance.
class DeductionHistorySection extends StatelessWidget {
  final AsyncValue<List<Order>> historyAsync;
  const DeductionHistorySection({super.key, required this.historyAsync});

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
