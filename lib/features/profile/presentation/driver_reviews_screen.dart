import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../orders/providers/driver_orders_provider.dart';

/// The driver's average rating and how many customers have rated them.
///
/// Kept on the driver's own row (drivers.rating / drivers.review_count) by a
/// database trigger each time a customer rates a delivery. Null when ratings
/// are not available yet -- the columns only exist once the database script
/// 20261011120000_receipt_confirmation_and_driver_ratings.sql has been run --
/// so the profile simply shows nothing until then.
final driverRatingSummaryProvider =
    FutureProvider.autoDispose<({double rating, int count})?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  try {
    final row = await Supabase.instance.client
        .from('drivers')
        .select('rating, review_count')
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return (
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      count: (row['review_count'] as num?)?.toInt() ?? 0,
    );
  } catch (_) {
    return null;
  }
});

/// One customer's rating of a delivery. No customer name: the driver sees
/// what was said, not who said it.
class DriverReview {
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const DriverReview({
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

/// The ratings this driver has received, newest first.
final driverReviewsProvider =
    FutureProvider.autoDispose<List<DriverReview>>((ref) async {
  final driverId = await ref.watch(currentDriverIdProvider.future);
  if (driverId == null) return const [];
  final rows = await Supabase.instance.client
      .from('driver_ratings')
      .select('rating, comment, created_at')
      .eq('driver_id', driverId)
      .order('created_at', ascending: false)
      .limit(100);
  return [
    for (final r in (rows as List).cast<Map<String, dynamic>>())
      DriverReview(
        rating: (r['rating'] as num?)?.toInt() ?? 0,
        comment: (r['comment'] as String?)?.trim(),
        createdAt:
            DateTime.tryParse('${r['created_at']}')?.toLocal() ?? DateTime.now(),
      ),
  ];
});

/// "My reviews": the average on top, then each rating with its comment.
class DriverReviewsScreen extends ConsumerWidget {
  const DriverReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final summary = ref.watch(driverRatingSummaryProvider).valueOrNull;
    final reviewsAsync = ref.watch(driverReviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myReviews,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(driverRatingSummaryProvider);
          ref.invalidate(driverReviewsProvider);
        },
        child: reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // Also the state before the database script has been run.
          error: (_, __) => _empty(l),
          data: (reviews) {
            if (reviews.isEmpty) return _empty(l);
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: reviews.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) return _summaryCard(l, summary, reviews.length);
                return _reviewTile(context, reviews[i - 1]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) {
    // A ListView so pull-to-refresh still works on the empty state.
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.star_border_rounded,
            size: 80, color: AppColors.textLight),
        const SizedBox(height: 16),
        Text(
          l.noReviewsYet,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          l.noReviewsYetHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _summaryCard(
    AppLocalizations l,
    ({double rating, int count})? summary,
    int loaded,
  ) {
    final rating = summary?.rating ?? 0;
    final count = summary?.count ?? loaded;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stars(rating.round(), size: 22, empty: Colors.white38),
                const SizedBox(height: 4),
                Text(
                  l.reviewsCount(count),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(BuildContext context, DriverReview review) {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = review.createdAt;
    final date = '${two(d.day)}/${two(d.month)}/${d.year}';
    final hasComment = review.comment != null && review.comment!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stars(review.rating, size: 18, empty: AppColors.textLight),
              const Spacer(),
              Text(
                date,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (hasComment) ...[
            const SizedBox(height: 8),
            Text(review.comment!),
          ],
        ],
      ),
    );
  }

  Widget _stars(int filled, {required double size, required Color empty}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: i < filled ? const Color(0xFFFFC107) : empty,
          ),
      ],
    );
  }
}
