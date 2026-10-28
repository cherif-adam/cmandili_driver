import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/privacy_policy.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import '../../../../core/providers/localization_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../edit_profile/edit_profile_screen.dart';
import '../../../notifications/presentation/notification/notification_screen.dart';
import '../vehicle_info/vehicle_info_screen.dart';
import '../my_contract/my_contract_screen.dart';
import '../driver_payout/driver_payout_screen.dart';
import '../driver_reviews/driver_reviews_screen.dart';
import '../../providers/driver_reviews_provider.dart';
import '../../../auth/presentation/change_password/change_password_screen.dart';
import '../help_support/help_support_screen.dart';
import '../../../account_deletion/presentation/delete_account/delete_account_screen.dart';
import 'profile_controller.dart';
import 'widgets/language_sheet.dart';
import 'widgets/profile_item.dart';

/// The profile tab: the header (initials, name, e-mail, rating), then the
/// account and settings entries, then log out. UI only: the actions live in
/// [ProfileController].
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    final controller = ref.watch(profileControllerProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localizationProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    // Null until customers can rate drivers (database script not run yet):
    // the rating line and the "My reviews" entry then simply do not appear.
    final ratingSummary = ref.watch(driverRatingSummaryProvider).valueOrNull;
    final displayName = ProfileController.displayName(currentUser);
    final displayEmail = currentUser?.email ?? '';
    final l = AppLocalizations.of(context)!;

    void open(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _ProfileHeader(
            displayName: displayName,
            displayEmail: displayEmail,
            ratingSummary: ratingSummary,
          ),
          SliverPadding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProfileSectionHeader(l.account, screenWidth: screenWidth),
                ProfileItem(
                  icon: Icons.person_outline_rounded,
                  title: l.editProfile,
                  onTap: () => open(const EditProfileScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                if (ratingSummary != null)
                  ProfileItem(
                    icon: Icons.star_outline_rounded,
                    title: l.myReviews,
                    trailing: ratingSummary.count > 0
                        ? '★ ${ratingSummary.rating.toStringAsFixed(1)}'
                        : null,
                    onTap: () => open(const DriverReviewsScreen()),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ProfileItem(
                  icon: Icons.two_wheeler_rounded,
                  title: l.vehicleInfo,
                  onTap: () => open(const VehicleInfoScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.description_outlined,
                  title: l.myContract,
                  onTap: () => open(const MyContractScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.account_balance_outlined,
                  title: l.earningsAndPayout,
                  onTap: () => open(const DriverPayoutScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(height: screenHeight * 0.03),
                ProfileSectionHeader(l.settings, screenWidth: screenWidth),
                ProfileItem(
                  icon: Icons.notifications_outlined,
                  title: l.notifications,
                  onTap: () => open(const NotificationScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.language_outlined,
                  title: l.language,
                  trailing: ProfileController.languageName(locale.languageCode),
                  onTap: () => showLanguageSheet(
                    context: context,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    current: () => ref.read(localizationProvider).languageCode,
                    onPick: (code) => controller.setLanguage(code),
                  ),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.brightness_6_outlined,
                  title: l.theme,
                  trailing: themeMode == ThemeMode.dark ? l.darkMode : l.lightMode,
                  onTap: () => controller.toggleTheme(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.lock_outline_rounded,
                  title: l.changePassword,
                  onTap: () => open(const ChangePasswordScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.help_outline_rounded,
                  title: l.helpSupport,
                  onTap: () => open(const HelpSupportScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                ProfileItem(
                  icon: Icons.privacy_tip_outlined,
                  title: l.privacyPolicy,
                  onTap: () => openPrivacyPolicy(context),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(height: screenHeight * 0.03),
                ProfileItem(
                  icon: Icons.logout_rounded,
                  title: l.logout,
                  textColor: AppColors.error,
                  iconColor: AppColors.error,
                  showArrow: false,
                  // Just sign out — _RootGate (main.dart) reacts to
                  // authStateProvider on its own and swaps to AuthScreen.
                  // The previous version pushed a bare AuthScreen and wiped
                  // the whole Navigator stack WITHOUT ever calling signOut(),
                  // which (a) left the Supabase session logged in underneath
                  // and (b) tore down _RootGate itself, so a later sign-in
                  // attempt had no widget left watching authStateProvider —
                  // the session updated but nothing was there to react to it.
                  onTap: () => controller.signOut(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                // Séparé du reste : c'est la seule action définitive de l'écran.
                SizedBox(height: screenHeight * 0.03),
                Divider(color: AppColors.error.withValues(alpha: 0.3)),
                SizedBox(height: screenHeight * 0.02),
                ProfileItem(
                  icon: Icons.delete_forever_rounded,
                  title: l.deleteAccount,
                  textColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: () => open(const DeleteAccountScreen()),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(height: screenHeight * 0.12), // Bottom padding for nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sections ──────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.displayEmail,
    required this.ratingSummary,
  });

  final String displayName;
  final String displayEmail;
  final ({double rating, int count})? ratingSummary;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final ratingSummary = this.ratingSummary;
    return SliverAppBar(
      expandedHeight: screenHeight * 0.25,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.125,
                  backgroundColor: Colors.white,
                  child: Text(
                    ProfileController.initials(displayName),
                    style: TextStyle(
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  displayEmail,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                if (ratingSummary != null && ratingSummary.count > 0) ...[
                  SizedBox(height: screenHeight * 0.008),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${ratingSummary.rating.toStringAsFixed(1)}  ·  '
                        '${AppLocalizations.of(context)!.reviewsCount(ratingSummary.count)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.036,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
