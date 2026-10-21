import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/tunisia_phone_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository());

/// One controller per edit-profile screen on display (the argument is a
/// key the screen creates for itself), auto-disposed with it like the State
/// it replaces. The text fields stay with the screen.
final editProfileControllerProvider = NotifierProvider.autoDispose
    .family<EditProfileController, EditProfileState, Object>(EditProfileController.new);

@immutable
class EditProfileState {
  const EditProfileState({this.imageFile, this.isSaving = false});

  /// The photo picked on the phone (not sent anywhere yet).
  final File? imageFile;
  final bool isSaving;
}

class EditProfileController extends AutoDisposeFamilyNotifier<EditProfileState, Object> {
  // ── State ─────────────────────────────────────────────────────────────────

  bool _disposed = false;
  final _picker = ImagePicker();

  @override
  EditProfileState build(Object screenKey) {
    ref.onDispose(() => _disposed = true);
    return const EditProfileState();
  }

  void _set({ValueGetter<File?>? imageFile, bool? isSaving}) {
    if (_disposed) return;
    state = EditProfileState(
      imageFile: imageFile != null ? imageFile() : state.imageFile,
      isSaving: isSaving ?? state.isSaving,
    );
  }

  // ── User actions ──────────────────────────────────────────────────────────

  /// The name and e-mail the fields start with, from the signed-in account.
  ({String name, String email}) initialIdentity() {
    final user = ref.read(authRepositoryProvider).currentUser;
    return (name: user?.displayName ?? '', email: user?.email ?? '');
  }

  /// The saved profile's name (null when not set) and phone (local digits),
  /// or null when there is no profile to read.
  Future<({String? fullName, String phone})?> loadProfile() async {
    final profile = await ref.read(profileRepositoryProvider).getUserProfile();
    if (profile == null) return null;
    return (
      fullName: profile['full_name'] as String?,
      phone: TunisiaPhoneField.toLocalDigits(profile['phone'] as String?),
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _set(imageFile: () => File(pickedFile.path));
    }
  }

  /// Saves the name (trimmed) and the phone. Returns whether it worked.
  Future<bool> save({required String fullName, required String phone}) async {
    _set(isSaving: true);
    final success = await ref.read(profileRepositoryProvider).updateProfile(
          fullName: fullName.trim(),
          phone: phone,
        );
    _set(isSaving: false);
    return success;
  }

  // ── Field rules ───────────────────────────────────────────────────────────

  static bool isMissing(String? value) => value!.isEmpty;
}
