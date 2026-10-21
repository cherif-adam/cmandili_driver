import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/driver_reviews_repository.dart';
import '../../providers/driver_reviews_provider.dart';
import 'driver_reviews_controller.dart';
import 'widgets/review_stars.dart';

/// "My reviews": the average on top, then each rating with its comment.
class DriverReviewsScreen extends ConsumerWidget {
  const DriverReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final controller = ref.watch(driverReviewsControllerProvider.notifier);
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
        onRefresh: () async => controller.refresh(),
        child: reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // Also the state before the database script has been run.
          error: (_, __) => const _ReviewsEmpty(),
          data: (reviews) {
            if (reviews.isEmpty) return const _ReviewsEmpty();
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: reviews.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) return _SummaryCard(summary: summary, loaded: reviews.length);
                return _ReviewTile(review: reviews[i - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Sections, in screen order ────────────────────────────────────────────────

class _ReviewsEmpty extends StatelessWidget {
  const _ReviewsEmpty();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.loaded});

  final ({double rating, int count})? summary;
  final int loaded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                ReviewStars(rating.round(), size: 22, empty: Colors.white38),
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
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final DriverReview review;

  @override
  Widget build(BuildContext context) {
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
              ReviewStars(review.rating, size: 18, empty: AppColors.textLight),
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
}
