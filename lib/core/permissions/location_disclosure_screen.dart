import 'package:flutter/material.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';

import '../theme/app_colors.dart';

/// What the driver reads before Android's location prompt (see
/// LocationDisclosure). Pops true for "Continue", false for "Not now".
class LocationDisclosureScreen extends StatelessWidget {
  const LocationDisclosureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_on_rounded, size: 56, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                l.locationDisclosureTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.locationDisclosureIntro, style: _body),
                      const SizedBox(height: 14),
                      _Point(Icons.delivery_dining_rounded, l.locationDisclosureUseOffers),
                      _Point(Icons.route_rounded, l.locationDisclosureUseTracking),
                      _Point(Icons.inventory_2_rounded, l.locationDisclosureUseProof),
                      const SizedBox(height: 14),
                      Text(l.locationDisclosureStop, style: _body),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l.locationDisclosureContinue,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.locationDisclosureNotNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _body = TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary);

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: _body)),
        ],
      ),
    );
  }
}
