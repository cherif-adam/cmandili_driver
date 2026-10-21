import 'package:supabase_flutter/supabase_flutter.dart';

/// The driver's vehicle, kept on their drivers row. Errors are left to the
/// caller.
class VehicleRepository {
  /// The signed-in driver, or null.
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  /// vehicle_type, vehicle_make, vehicle_model, vehicle_plate and
  /// vehicle_color, or null when the driver has no row yet.
  Future<Map<String, dynamic>?> fetchVehicle(String userId) {
    return Supabase.instance.client
        .from('drivers')
        .select('vehicle_type, vehicle_make, vehicle_model, vehicle_plate, vehicle_color')
        .eq('user_id', userId)
        .maybeSingle();
  }

  /// Upsert so this works whether or not a drivers row already exists for
  /// this user. update().eq() silently writes 0 rows if the row is missing,
  /// which would leave vehicle_type null and trap the user on this screen.
  Future<void> saveVehicle(
    String userId, {
    required String type,
    required String make,
    required String model,
    required String plate,
    required String color,
  }) async {
    await Supabase.instance.client.from('drivers').upsert({
      'user_id': userId,
      'vehicle_type': type,
      'vehicle_make': make,
      'vehicle_model': model,
      'vehicle_plate': plate,
      'vehicle_color': color,
    }, onConflict: 'user_id');
  }
}
