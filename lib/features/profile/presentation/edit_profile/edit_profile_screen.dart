import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tunisia_phone_field.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import 'edit_profile_controller.dart';

/// Edit profile: photo, then name, e-mail (read only), phone and bio, then
/// save. UI only: reading and saving live in [EditProfileController].
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  /// This screen's own controller (see [editProfileControllerProvider]).
  late final _provider = editProfileControllerProvider(Object());

  EditProfileController get _controller => ref.read(_provider.notifier);

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final identity = _controller.initialIdentity();
    _nameController = TextEditingController(text: identity.name);
    _emailController = TextEditingController(text: identity.email);
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _controller.loadProfile();
    if (!mounted || profile == null) return;
    setState(() {
      _nameController.text = profile.fullName ?? _nameController.text;
      _phoneController.text = profile.phone;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _controller.save(
      fullName: _nameController.text,
      phone: TunisiaPhoneField.normalize(_phoneController),
    );
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l.profileUpdated : l.failedToUpdateProfile),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(_provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              _ProfilePhoto(imageFile: s.imageFile, onPick: () => _controller.pickImage()),
              SizedBox(height: size.height * 0.04),

              _ProfileFields(
                name: _nameController,
                email: _emailController,
                phone: _phoneController,
                bio: _bioController,
              ),

              SizedBox(height: size.height * 0.05),

              _SaveButton(isSaving: s.isSaving, onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sections ──────────────────────────────────────────────────────────────────

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.imageFile, required this.onPick});

  final File? imageFile;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Stack(
        children: [
          Container(
            width: size.width * 0.3,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              image: imageFile != null
                  ? DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400'),
                      fit: BoxFit.cover,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFields extends StatelessWidget {
  const _ProfileFields({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController bio;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        _ProfileTextField(
          controller: name,
          label: l.fullName,
          icon: Icons.person_outline,
          validator: (value) => EditProfileController.isMissing(value) ? l.pleaseEnterName : null,
        ),
        SizedBox(height: size.height * 0.02),

        _ProfileTextField(
          controller: email,
          label: l.email,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: false, // Email usually not editable directly
        ),
        SizedBox(height: size.height * 0.02),

        TunisiaPhoneField(
          controller: phone,
          label: l.phoneNumberLabel,
          invalidMessage: l.phoneInvalid,
          required: false,
        ),
        SizedBox(height: size.height * 0.02),

        _ProfileTextField(
          controller: bio,
          label: l.bio,
          icon: Icons.info_outline,
          maxLines: 3,
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
