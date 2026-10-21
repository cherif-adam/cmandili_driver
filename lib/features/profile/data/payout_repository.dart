import 'package:supabase_flutter/supabase_flutter.dart';

/// The driver's prepaid wallet and payout bank details. Errors are left to
/// the caller.
class PayoutRepository {
  /// The signed-in driver, or null.
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  /// The prepaid balance of [userId], or null when there is no wallet row.
  Future<double?> walletBalance(String userId) async {
    final row = await Supabase.instance.client
        .from('wallets')
        .select('balance')
        .eq('user_id', userId)
        .maybeSingle();
    return (row?['balance'] as num?)?.toDouble();
  }

  /// The saved payout details of [userId], or null.
  Future<Map<String, dynamic>?> payoutInfo(String userId) {
    return Supabase.instance.client
        .from('driver_payout_info')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<void> savePayoutInfo({
    required String userId,
    required String bankName,
    required String iban,
    required String accountHolder,
  }) async {
    await Supabase.instance.client.from('driver_payout_info').upsert({
      'user_id': userId,
      'bank_name': bankName,
      'iban': iban,
      'account_holder': accountHolder,
    }, onConflict: 'user_id');
  }
}
