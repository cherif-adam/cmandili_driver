import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/providers/driver_online_provider.dart';
import '../../providers/driver_wallet_provider.dart';

/// One controller per payout screen on display (the argument is a key the
/// screen creates for itself), auto-disposed with it like the State it
/// replaces. The balance comes from driverWalletProvider, the deductions
/// from driverDeliveryHistoryProvider; the bank fields stay with the screen.
final driverPayoutControllerProvider = NotifierProvider.autoDispose
    .family<DriverPayoutController, DriverPayoutState, Object>(DriverPayoutController.new);

@immutable
class DriverPayoutState {
  const DriverPayoutState({this.loading = true, this.saving = false});

  final bool loading;
  final bool saving;
}

/// The saved bank details.
typedef PayoutFields = ({String bankName, String iban, String accountHolder});

class DriverPayoutController extends AutoDisposeFamilyNotifier<DriverPayoutState, Object> {
  // ── State ─────────────────────────────────────────────────────────────────

  bool _disposed = false;

  @override
  DriverPayoutState build(Object screenKey) {
    ref.onDispose(() => _disposed = true);
    // Signed out: nothing to read, the form shows at once.
    final signedIn = ref.read(payoutRepositoryProvider).currentUserId != null;
    return DriverPayoutState(loading: signedIn);
  }

  void _set({bool? loading, bool? saving}) {
    if (_disposed) return;
    state = DriverPayoutState(
      loading: loading ?? state.loading,
      saving: saving ?? state.saving,
    );
  }

  // ── User actions ──────────────────────────────────────────────────────────

  /// The saved bank details for the screen to fill, or null (none saved,
  /// signed out, or unreadable). The screen calls [loaded] once they are in.
  Future<PayoutFields?> load() async {
    final repository = ref.read(payoutRepositoryProvider);
    final userId = repository.currentUserId;
    if (userId == null) return null;
    try {
      final row = await repository.payoutInfo(userId);
      if (row != null) {
        return (
          bankName: row['bank_name'] as String? ?? '',
          iban: row['iban'] as String? ?? '',
          accountHolder: row['account_holder'] as String? ?? '',
        );
      }
    } catch (_) {}
    return null;
  }

  void loaded() => _set(loading: false);

  /// Saves the bank details (trimmed). Throws when signed out or when the
  /// write fails.
  Future<void> save({
    required String bankName,
    required String iban,
    required String accountHolder,
  }) async {
    _set(saving: true);
    try {
      final repository = ref.read(payoutRepositoryProvider);
      final userId = repository.currentUserId;
      if (userId == null) throw 'Not authenticated';
      await repository.savePayoutInfo(
        userId: userId,
        bankName: bankName.trim(),
        iban: iban.trim(),
        accountHolder: accountHolder.trim(),
      );
    } finally {
      _set(saving: false);
    }
  }

  /// The online switch, unchanged: driverOnlineProvider does the work.
  void setOnline(bool next) => ref.read(driverOnlineProvider.notifier).setOnline(next);

  // ── Field rules ───────────────────────────────────────────────────────────

  static bool isMissing(String? value) => value!.isEmpty;

  static bool isIbanTooShort(String? value) => value!.length < 10;
}
