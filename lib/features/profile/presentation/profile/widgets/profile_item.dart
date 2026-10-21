import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// A section title in the profile list.
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader(this.title, {super.key, required this.screenWidth});

  final String title;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: screenWidth * 0.04,
        left: screenWidth * 0.01,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}

/// One row of the profile list: icon, title, optional value, arrow.
class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
    this.trailing,
    this.textColor,
    this.iconColor,
    this.showArrow = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;
  final String? trailing;
  final Color? textColor;
  final Color? iconColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, screenHeight * 0.006),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withValues(alpha:0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: screenWidth * 0.055,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.6),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                if (showArrow) ...[
                  SizedBox(width: screenWidth * 0.02),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: screenWidth * 0.04,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.4),
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
