import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vehicle_repository.dart';

final vehicleRepositoryProvider =
    Provider<VehicleRepository>((ref) => VehicleRepository());

/// One controller per vehicle screen on display (the argument is a key the
/// screen creates for itself), auto-disposed with it like the State it
/// replaces.
final vehicleInfoControllerProvider = NotifierProvider.autoDispose
    .family<VehicleInfoController, VehicleInfoState, Object>(VehicleInfoController.new);

@immutable
class VehicleInfoState {
  const VehicleInfoState({
    this.vehicleType = 'motorcycle',
    this.loading = true,
    this.saving = false,
  });

  final String vehicleType;
  final bool loading;
  final bool saving;
}

/// The saved vehicle's text fields.
typedef VehicleFields = ({String make, String model, String plate, String color});

class VehicleInfoController extends AutoDisposeFamilyNotifier<VehicleInfoState, Object> {
  // ── State ─────────────────────────────────────────────────────────────────

  bool _disposed = false;

  static const vehicleTypes = ['motorcycle', 'car', 'bicycle', 'scooter'];

  @override
  VehicleInfoState build(Object screenKey) {
    ref.onDispose(() => _disposed = true);
    // Signed out: nothing to read, the form shows at once.
    final signedIn = ref.read(vehicleRepositoryProvider).currentUserId != null;
    return VehicleInfoState(loading: signedIn);
  }

  void _set({String? vehicleType, bool? loading, bool? saving}) {
    if (_disposed) return;
    state = VehicleInfoState(
      vehicleType: vehicleType ?? state.vehicleType,
      loading: loading ?? state.loading,
      saving: saving ?? state.saving,
    );
  }

  // ── User actions ──────────────────────────────────────────────────────────

  /// Reads the saved vehicle: its type goes into the state, its text fields
  /// are returned for the screen to fill (null when there is none or it
  /// could not be read). The screen calls [loaded] once they are filled.
  Future<VehicleFields?> load() async {
    final repository = ref.read(vehicleRepositoryProvider);
    final userId = repository.currentUserId;
    if (userId == null) return null;
    try {
      final row = await repository.fetchVehicle(userId);
      if (row != null) {
        final type = row['vehicle_type'] as String? ?? 'motorcycle';
        final fields = (
          make: row['vehicle_make'] as String? ?? '',
          model: row['vehicle_model'] as String? ?? '',
          plate: row['vehicle_plate'] as String? ?? '',
          color: row['vehicle_color'] as String? ?? '',
        );
        _set(vehicleType: type);
        return fields;
      }
    } catch (_) {}
    return null;
  }

  void loaded() => _set(loading: false);

  void setVehicleType(String type) => _set(vehicleType: type);

  /// Saves the vehicle (fields trimmed). Throws when signed out or when the
  /// write fails.
  Future<void> save({
    required String make,
    required String model,
    required String plate,
    required String color,
  }) async {
    _set(saving: true);
    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = repository.currentUserId;
      if (userId == null) throw 'Not authenticated';
      await repository.saveVehicle(
        userId,
        type: state.vehicleType,
        make: make.trim(),
        model: model.trim(),
        plate: plate.trim(),
        color: color.trim(),
      );
    } finally {
      _set(saving: false);
    }
  }

  // ── Field rules ───────────────────────────────────────────────────────────

  /// Make and plate are required.
  static bool isMissing(String? value) => value!.isEmpty;
}
