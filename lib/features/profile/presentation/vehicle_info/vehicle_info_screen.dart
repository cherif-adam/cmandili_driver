import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import 'vehicle_info_controller.dart';

/// The driver's vehicle: type, then make, model, plate and colour, then
/// save. UI only: reading and saving live in [VehicleInfoController].
class VehicleInfoScreen extends ConsumerStatefulWidget {
  const VehicleInfoScreen({super.key, this.onSaved});

  /// Called after a successful save. Used by the post-auth gate to re-check
  /// whether the driver can now enter the app, since this screen is rendered
  /// as the root of an inner Navigator where Navigator.pop is a no-op.
  final VoidCallback? onSaved;

  @override
  ConsumerState<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends ConsumerState<VehicleInfoScreen> {
  /// This screen's own controller (see [vehicleInfoControllerProvider]).
  late final _provider = vehicleInfoControllerProvider(Object());

  VehicleInfoController get _controller => ref.read(_provider.notifier);

  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fields = await _controller.load();
    if (fields != null) {
      _makeCtrl.text = fields.make;
      _modelCtrl.text = fields.model;
      _plateCtrl.text = fields.plate;
      _colorCtrl.text = fields.color;
    }
    if (mounted) _controller.loaded();
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _controller.save(
        make: _makeCtrl.text,
        model: _modelCtrl.text,
        plate: _plateCtrl.text,
        color: _colorCtrl.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.vehicleInfoSaved), backgroundColor: Colors.green),
        );
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(_provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.vehicleInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: s.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _VehicleTypePicker(
                      selected: s.vehicleType,
                      onSelect: (t) => _controller.setVehicleType(t),
                    ),
                    const SizedBox(height: 20),
                    _VehicleFields(
                      make: _makeCtrl,
                      model: _modelCtrl,
                      plate: _plateCtrl,
                      color: _colorCtrl,
                    ),
                    const SizedBox(height: 32),
                    _SaveButton(saving: s.saving, onPressed: _save),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Sections ──────────────────────────────────────────────────────────────────

class _VehicleTypePicker extends StatelessWidget {
  const _VehicleTypePicker({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vehicle type selector
        Text(l.vehicleType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: VehicleInfoController.vehicleTypes.map((t) {
            final isSelected = t == selected;
            return ChoiceChip(
              label: Text(t[0].toUpperCase() + t.substring(1)),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onSelect(t),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _VehicleFields extends StatelessWidget {
  const _VehicleFields({
    required this.make,
    required this.model,
    required this.plate,
    required this.color,
  });

  final TextEditingController make;
  final TextEditingController model;
  final TextEditingController plate;
  final TextEditingController color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String? required(String? v) => VehicleInfoController.isMissing(v) ? l.required : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VehicleField(controller: make, label: l.vehicleMakeHint, icon: Icons.directions_car_outlined,
            validator: required),
        const SizedBox(height: 16),
        _VehicleField(controller: model, label: l.vehicleModelHint, icon: Icons.two_wheeler_rounded),
        const SizedBox(height: 16),
        _VehicleField(controller: plate, label: l.licensePlate, icon: Icons.credit_card_outlined,
            validator: required),
        const SizedBox(height: 16),
        _VehicleField(controller: color, label: l.color, icon: Icons.palette_outlined),
      ],
    );
  }
}

class _VehicleField extends StatelessWidget {
  const _VehicleField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onPressed});

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: saving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: saving
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(l.saveVehicleInfo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
