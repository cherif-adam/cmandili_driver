import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/providers/driver_orders_provider.dart';
import '../data/earnings_repository.dart';

final earningsRepositoryProvider =
    Provider<EarningsRepository>((ref) => EarningsRepository());

/// When [period] ('today', 'week', anything else: the month) began.
DateTime earningsPeriodStart(String period, DateTime now) {
  DateTime start;
  if (period == 'today') {
    start = DateTime(now.year, now.month, now.day);
  } else if (period == 'week') {
    start = now.subtract(Duration(days: now.weekday - 1));
    start = DateTime(start.year, start.month, start.day);
  } else {
    start = DateTime(now.year, now.month, 1);
  }
  return start;
}

/// {'total': double, 'count': int} for the period, from its start until now.
final earningsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, period) async {
  final driverId = await ref.watch(currentDriverIdProvider.future);
  if (driverId == null) return {'total': 0.0, 'count': 0};

  final now = DateTime.now();
  final result = await ref.read(earningsRepositoryProvider).fetchEarnings(
        driverId,
        start: earningsPeriodStart(period, now),
        end: now,
      );
  return {'total': result.total, 'count': result.count};
});
