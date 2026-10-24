import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// Badge + title + subtitle shared by the three steps.
class StepIntro extends StatelessWidget {
  const StepIntro({
    required this.badgeIcon,
    required this.badge,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData badgeIcon;
  final String badge;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        InfoPill(
          icon: badgeIcon,
          iconColor: AppColors.primary,
          label: badge,
          background: AppColors.secondaryContainer40,
          foreground: AppColors.primary,
          textStyle: AppTypography.labelSm.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: AppTypography.headlineLg.copyWith(color: AppColors.onSurface),
        ),
        Text(
          subtitle,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
