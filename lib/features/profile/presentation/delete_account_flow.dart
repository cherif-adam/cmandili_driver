import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_repository.dart'
    show AccountDeletionError, AccountDeletionException;
import '../../auth/providers/auth_provider.dart';

/// Profil -> "Supprimer mon compte": confirms, deletes the account, then
/// signs out (main.dart's _RootGate swaps to the login screen, and signOut
/// stops the GPS service). Refused during a delivery or with a negative
/// balance; the account is then left untouched.
Future<void> deleteDriverAccount(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.delete_forever_rounded,
          color: AppColors.error, size: 36),
      title: Text(l.deleteAccountTitle),
      content: SingleChildScrollView(
        child: Text(l.deleteAccountBody, style: const TextStyle(height: 1.4)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l.deleteAccountConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  // Blocks the screen for the few seconds the deletion takes.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  try {
    await ref.read(authRepositoryProvider).deleteAccount();
    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(SnackBar(content: Text(l.deleteAccountDone)));
  } on AccountDeletionException catch (e) {
    navigator.pop(); // the progress dialog
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (e.error) {
          AccountDeletionError.activeDelivery => l.deleteAccountActiveDelivery,
          AccountDeletionError.negativeBalance => l.deleteAccountNegativeBalance,
          AccountDeletionError.failed => l.deleteAccountFailed,
        }),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
