import 'package:supabase_flutter/supabase_flutter.dart';

/// Support tickets opened from the help screen.
class SupportRepository {
  /// The signed-in driver, or null.
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  /// Opens a ticket. Errors propagate: the screen shows its own message.
  Future<void> createTicket({
    required String userId,
    required String subject,
    required String message,
  }) async {
    await Supabase.instance.client.from('support_tickets').insert({
      'user_id': userId,
      'subject': subject,
      'message': message,
      'status': 'open',
    });
  }
}
