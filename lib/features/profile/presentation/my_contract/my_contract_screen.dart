import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../orders/providers/driver_orders_provider.dart'
    show currentDriverIdProvider;
import '../../data/driver_contract_repository.dart';

final driverContractRepositoryProvider =
    Provider<DriverContractRepository>((ref) => DriverContractRepository());

/// The signed-in driver's contract (null: none sent yet).
final myContractProvider =
    FutureProvider.autoDispose<DriverContract?>((ref) async {
  final driverId = await ref.watch(currentDriverIdProvider.future);
  if (driverId == null) return null;
  return ref.read(driverContractRepositoryProvider).fetch(driverId);
});

/// "Mon contrat": the Amana team sends the contract here; the driver
/// downloads it, signs it, has the signature legalized at the baladiya, then
/// sends back a photo. The team checks it in the admin dashboard.
///
///   _StatusCard, then (until approved) _Steps with the two buttons.
class MyContractScreen extends ConsumerStatefulWidget {
  const MyContractScreen({super.key});

  @override
  ConsumerState<MyContractScreen> createState() => _MyContractScreenState();
}

class _MyContractScreenState extends ConsumerState<MyContractScreen> {
  bool _busy = false;

  Future<void> _download(DriverContract contract) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await ref
          .read(driverContractRepositoryProvider)
          .downloadUrl(contract.toSignPath!);
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('no app');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.contractDownloadFailed)));
    }
  }

  Future<void> _sendPhoto() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l.contractTakePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.contractChooseGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2200,
    );
    if (picked == null) return;

    setState(() => _busy = true);
    try {
      final driverId = await ref.read(currentDriverIdProvider.future);
      if (driverId == null) throw Exception('no driver');
      final bytes = await picked.readAsBytes();
      final ext = picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      await ref.read(driverContractRepositoryProvider).submitSigned(
            driverId: driverId,
            bytes: bytes,
            extension: ext,
          );
      ref.invalidate(myContractProvider);
      messenger.showSnackBar(SnackBar(
        content: Text(l.contractSent),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      debugPrint('send signed contract: $e');
      messenger.showSnackBar(SnackBar(
        content: Text(l.contractSendFailed),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final contractAsync = ref.watch(myContractProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myContract,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: contractAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l.contractNone)),
        data: (contract) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(myContractProvider),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _StatusCard(contract: contract),
              if (contract != null &&
                  contract.status != DriverContractStatus.approved) ...[
                const SizedBox(height: 20),
                _Steps(
                  busy: _busy,
                  canDownload: contract.toSignPath != null,
                  resend: contract.status == DriverContractStatus.submitted,
                  onDownload: () => _download(contract),
                  onSendPhoto: _sendPhoto,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Coloured box saying where the contract stands (and why it was refused).
class _StatusCard extends StatelessWidget {
  final DriverContract? contract;

  const _StatusCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (IconData icon, Color color, String text) = switch (contract?.status) {
      null => (Icons.hourglass_empty_rounded, AppColors.textSecondary, l.contractNone),
      DriverContractStatus.sent => (Icons.edit_document, AppColors.primary, l.contractStatusSent),
      DriverContractStatus.submitted => (Icons.schedule_rounded, Colors.orange, l.contractStatusSubmitted),
      DriverContractStatus.approved => (Icons.verified_rounded, AppColors.success, l.contractStatusApproved),
      DriverContractStatus.rejected => (Icons.error_outline_rounded, AppColors.error, l.contractStatusRejected),
    };
    final note = contract?.status == DriverContractStatus.rejected
        ? contract?.adminNote
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, height: 1.4)),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${l.contractReason} $note',
                      style: TextStyle(color: color, height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The four steps, with the download and send buttons.
class _Steps extends StatelessWidget {
  final bool busy;
  final bool canDownload;
  final bool resend;
  final VoidCallback onDownload;
  final VoidCallback onSendPhoto;

  const _Steps({
    required this.busy,
    required this.canDownload,
    required this.resend,
    required this.onDownload,
    required this.onSendPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Widget step(String n, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text(n,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        step('1', l.contractStep1),
        step('2', l.contractStep2),
        step('3', l.contractStep3),
        step('4', l.contractStep4),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: canDownload && !busy ? onDownload : null,
          icon: const Icon(Icons.download_rounded),
          label: Text(l.contractDownload),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: busy ? null : onSendPhoto,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.photo_camera_rounded),
          label: Text(resend ? l.contractResendPhoto : l.contractSendPhoto),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
