import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/localization_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/providers/auth_provider.dart';

/// The profile tab's actions. What it shows comes from authStateProvider,
/// themeProvider, localizationProvider and driverRatingSummaryProvider.
/// Kept alive by the screen watching it.
final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileController, void>(ProfileController.new);

class ProfileController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  // ── User actions ──────────────────────────────────────────────────────────

  void setLanguage(String code) =>
      ref.read(localizationProvider.notifier).setLocale(Locale(code));

  void toggleTheme() => ref.read(themeProvider.notifier).toggleTheme();

  /// Just sign out — _RootGate (main.dart) reacts to authStateProvider on
  /// its own and swaps to AuthScreen.
  void signOut() => ref.read(authRepositoryProvider).signOut();

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String displayName(User? user) =>
      user?.displayName ?? user?.email?.split('@').first ?? '';

  static String initials(String displayName) =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

  static String languageName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'fr': return 'Français';
      default: return 'English';
    }
  }
}
