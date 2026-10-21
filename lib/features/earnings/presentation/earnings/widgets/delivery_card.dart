import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../orders/data/models/order.dart';

/// Recent-deliveries card label — type-aware so a driver can tell what they
/// actually delivered, not just an opaque order ID. Same fallback shape as
/// available_orders_screen's _orderTitle, but food/supermarket orders show
/// the item names here instead of the restaurant name, since that's the
/// more useful "what was this" cue in a historical list.
String _deliveryPrimaryLabel(Order order) {
  switch (order.type) {
    case OrderType.courier:
      final desc = order.packageDescription?.trim();
      return (desc != null && desc.isNotEmpty) ? desc : 'Colis';
    case OrderType.facture:
    case OrderType.billPayment:
      return 'Facture';
    default:
      final summary = order.contentSummary?.trim();
      if (summary != null && summary.isNotEmpty) return summary;
      return order.restaurantName.isNotEmpty
          ? order.restaurantName
          : 'Order #${order.id.substring(0, 8).toUpperCase()}';
  }
}

/// "Collecté: 3.500 DT — Commission: -0.805 DT — Net: 2.695 DT", with a
/// "Subvention" field inserted when a loyalty subsidy applies. Net always
/// equals what a normal full-price delivery would have netted, since the
/// subsidy exists specifically to make loyalty-discounted deliveries earn
/// the same as full-price ones. Null when there's no commission_deduction
/// settlement for this order yet (generate_settlements_on_delivery() is
/// cash-only, so non-cash orders never get one).
String? _commissionBreakdownText(Order order) {
  final commission = order.commissionAmount;
  if (commission == null) return null;
  final collected = order.deliveryFee;
  final subsidy = order.loyaltySubsidyAmount;
  final net = collected + commission + (subsidy ?? 0);
  final parts = [
    'Collecté: ${collected.toStringAsFixed(3)} DT',
    'Commission: ${commission.toStringAsFixed(3)} DT',
    if (subsidy != null) 'Subvention: +${subsidy.toStringAsFixed(3)} DT',
    'Net: ${net.toStringAsFixed(3)} DT',
  ];
  return parts.join(' — ');
}

/// One finished delivery: what it was, where, what it paid, and the
/// commission breakdown when there is one.
class DeliveryCard extends StatelessWidget {
  const DeliveryCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final breakdown = _commissionBreakdownText(order);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deliveryPrimaryLabel(order),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#${order.id.substring(0, 8).toUpperCase()} · ${order.deliveryAddress.fullAddress.isNotEmpty ? order.deliveryAddress.fullAddress : order.deliveryAddress.label}',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '+${order.deliveryFee.toStringAsFixed(2)} DT',
                style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ],
          ),
          if (breakdown != null) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: AppColors.background),
            const SizedBox(height: 8),
            Text(
              breakdown,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}
