import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/payments/presentation/payments_strings.dart';

/// Footnote explaining the Friday → Thursday, Saturday → Sunday rule.
class WeekendRuleCard extends StatelessWidget {
  const WeekendRuleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceContainerLow,
      shadows: const [],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: Icons.policy_outlined,
            background: AppColors.primaryFixed,
            foreground: AppColors.onPrimaryFixed,
            size: 36,
          ),
          const SizedBox(width: AppSpacing.gutterSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  PaymentsStrings.weekendRuleTitle,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  PaymentsStrings.weekendRuleBody,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
