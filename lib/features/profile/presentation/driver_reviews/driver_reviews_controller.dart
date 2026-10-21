import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/driver_reviews_provider.dart';

/// The reviews screen's one action: pull to refresh. The data comes from
/// driverRatingSummaryProvider and driverReviewsProvider. Kept alive by the
/// screen watching it.
final driverReviewsControllerProvider =
    NotifierProvider.autoDispose<DriverReviewsController, void>(DriverReviewsController.new);

class DriverReviewsController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  /// Reads the average and the reviews again.
  void refresh() {
    ref.invalidate(driverRatingSummaryProvider);
    ref.invalidate(driverReviewsProvider);
  }
}
