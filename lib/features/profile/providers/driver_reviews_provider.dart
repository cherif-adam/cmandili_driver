import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/providers/driver_orders_provider.dart';
import '../data/driver_reviews_repository.dart';

final driverReviewsRepositoryProvider =
    Provider<DriverReviewsRepository>((ref) => DriverReviewsRepository());

/// The driver's average rating and how many customers have rated them.
///
/// Kept on the driver's own row (drivers.rating / drivers.review_count) by a
/// database trigger each time a customer rates a delivery. Null when ratings
/// are not available yet -- the columns only exist once the database script
/// 20261011120000_receipt_confirmation_and_driver_ratings.sql has been run --
/// so the profile simply shows nothing until then.
final driverRatingSummaryProvider =
    FutureProvider.autoDispose<({double rating, int count})?>((ref) async {
  final repository = ref.read(driverReviewsRepositoryProvider);
  final userId = repository.currentUserId;
  if (userId == null) return null;
  try {
    return await repository.fetchSummary(userId);
  } catch (_) {
    return null;
  }
});

/// The ratings this driver has received, newest first.
final driverReviewsProvider =
    FutureProvider.autoDispose<List<DriverReview>>((ref) async {
  final driverId = await ref.watch(currentDriverIdProvider.future);
  if (driverId == null) return const [];
  return ref.read(driverReviewsRepositoryProvider).fetchReviews(driverId);
});
