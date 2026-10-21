import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Prepaid balance summary. When the balance is at or below zero the driver is
/// blocked from receiving orders, so we show a prominent red recharge banner.
class PrepaidBalanceCard extends StatelessWidget {
  final double? balance;

  const PrepaidBalanceCard({super.key, required this.balance});

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
