import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// Brand header with notification and help actions.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.hasUnreadNotifications = true,
    this.onNotificationsPressed,
    this.onHelpPressed,
  });

  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onHelpPressed;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.black12,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSizes.topBarHeight,
          child: Padding(
            padding: AppSpacing.screen,
            child: Row(
              children: [
                const BrandAvatar(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        AppStrings.appTagline,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _BarAction(
                  icon: Icons.notifications_outlined,
                  tooltip: AppStrings.notifications,
                  showBadge: hasUnreadNotifications,
                  onPressed: onNotificationsPressed,
                ),
                _BarAction(
                  icon: Icons.help_outline,
                  tooltip: AppStrings.help,
                  onPressed: onHelpPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: onPressed ?? () {},
          tooltip: tooltip,
          iconSize: 22,
          color: AppColors.onSurfaceVariant,
          constraints: const BoxConstraints.tightFor(
            width: AppSizes.minTouchTarget,
            height: AppSizes.minTouchTarget,
          ),
          icon: Icon(icon),
        ),
        if (showBadge)
          Positioned(
            top: 10,
            left: 10,
            child: IgnorePointer(
              child: Dot(color: AppColors.secondary, size: 8),
            ),
          ),
      ],
    );
  }
}
