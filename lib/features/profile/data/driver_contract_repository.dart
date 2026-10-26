import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Where the contract exchange with the Amana team stands
/// (table driver_contracts, migration 20261026120000).
enum DriverContractStatus { sent, submitted, approved, rejected }

class DriverContract {
  final DriverContractStatus status;
  final String? toSignPath;
  final String? signedPath;
  final String? adminNote;

  const DriverContract({
    required this.status,
    this.toSignPath,
    this.signedPath,
    this.adminNote,
  });

  factory DriverContract.fromJson(Map<String, dynamic> json) {
    return DriverContract(
      status: DriverContractStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DriverContractStatus.sent,
      ),
      toSignPath: json['to_sign_path'] as String?,
      signedPath: json['signed_path'] as String?,
      adminNote: json['admin_note'] as String?,
    );
  }
}

/// The contract the admin sends, and the photo of the signed and legalized
/// contract the driver sends back. Files live in the PRIVATE bucket
/// driver-contracts; the driver can only read to_sign/<his id>/ and
/// signed/<his id>/, and only write to signed/<his id>/.
class DriverContractRepository {
  static const _bucket = 'driver-contracts';
  final _supabase = Supabase.instance.client;

  /// The driver's contract, or null when none was sent yet (or the
  /// migration isn't applied yet: the screen then simply says "none").
  Future<DriverContract?> fetch(String driverId) async {
    try {
      final row = await _supabase
          .from('driver_contracts')
          .select('status, to_sign_path, signed_path, admin_note')
          .eq('driver_id', driverId)
          .maybeSingle();
      return row == null ? null : DriverContract.fromJson(row);
    } catch (e) {
      debugPrint('driver contract fetch: $e');
      return null;
    }
  }

  /// A 10-minute link to download the contract to sign.
  Future<String> downloadUrl(String toSignPath) {
    return _supabase.storage.from(_bucket).createSignedUrl(toSignPath, 600);
  }

  /// Uploads the photo of the signed contract, then hands it to the team.
  /// A new path each time: nothing is ever overwritten.
  Future<void> submitSigned({
    required String driverId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final path =
        'signed/$driverId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: extension == 'png' ? 'image/png' : 'image/jpeg',
            upsert: false,
          ),
        );
    await _supabase.rpc('submit_signed_contract', params: {'p_path': path});
  }
}
