import 'package:supabase_flutter/supabase_flutter.dart';

/// The driver's earnings over a period, from get_driver_earnings. Errors are
/// left to the caller.
class EarningsRepository {
  /// Total earned and number of deliveries between [start] and [end].
  Future<({double total, int count})> fetchEarnings(
    String driverId, {
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await Supabase.instance.client.rpc('get_driver_earnings', params: {
      'p_driver_id': driverId,
      // Postgres receives these as timestamptz. Without an explicit UTC
      // conversion, a naive local-time string carries no zone info and gets
      // interpreted as UTC, silently shifting the "today" boundary by the
      // driver's own UTC offset.
      'p_start_date': start.toUtc().toIso8601String(),
      'p_end_date': end.toUtc().toIso8601String(),
    });
    if (result is Map) {
      return (
        total: (result['total'] as num?)?.toDouble() ?? 0.0,
        count: (result['count'] as num?)?.toInt() ?? 0,
      );
    }
    return (total: 0.0, count: 0);
  }
}
