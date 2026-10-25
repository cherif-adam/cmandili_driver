import 'package:supabase_flutter/supabase_flutter.dart';

/// The driver's prepaid wallet. Errors are left to the caller.
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
}
