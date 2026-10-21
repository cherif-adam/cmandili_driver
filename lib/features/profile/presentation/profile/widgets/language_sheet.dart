import 'package:flutter/material.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';

/// The three languages; [current] gives the one in use (read while the
/// sheet builds), [onPick] gets the chosen code, then the sheet closes.
void showLanguageSheet({
  required BuildContext context,
  required double screenWidth,
  required double screenHeight,
  required String Function() current,
  required ValueChanged<String> onPick,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.055,
                ),
          ),
          SizedBox(height: screenHeight * 0.03),
          _LanguageOption(name: 'English', code: 'en', screenWidth: screenWidth, current: current, onPick: onPick),
          _LanguageOption(name: 'العربية', code: 'ar', screenWidth: screenWidth, current: current, onPick: onPick),
          _LanguageOption(name: 'Français', code: 'fr', screenWidth: screenWidth, current: current, onPick: onPick),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    ),
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.name,
    required this.code,
    required this.screenWidth,
    required this.current,
    required this.onPick,
  });

  final String name;
  final String code;
  final double screenWidth;
  final String Function() current;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final isSelected = current() == code;
    return ListTile(
      title: Text(
        name,
        style: TextStyle(fontSize: screenWidth * 0.04),
      ),
      trailing: isSelected ? Icon(Icons.check, color: AppColors.primary, size: screenWidth * 0.06) : null,
      onTap: () {
        onPick(code);
        Navigator.pop(context);
      },
    );
  }
}
