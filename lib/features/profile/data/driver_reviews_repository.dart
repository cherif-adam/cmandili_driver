import 'package:supabase_flutter/supabase_flutter.dart';

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

/// The ratings customers gave the driver. Errors are left to the caller.
class DriverReviewsRepository {
  /// The signed-in driver's user id, or null.
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  /// drivers.rating and drivers.review_count, or null when the driver has
  /// no row.
  Future<({double rating, int count})?> fetchSummary(String userId) async {
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
  }

  /// The ratings this driver has received, newest first (100 at most).
  Future<List<DriverReview>> fetchReviews(String driverId) async {
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
  }
}
