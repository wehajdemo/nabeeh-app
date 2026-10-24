import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/presentation/upgrade_strings.dart';

/// Shown instead of the plans when the user already has Plus.
class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard({
    required this.entitlement,
    required this.onManage,
    super.key,
  });

  final PlusEntitlement entitlement;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final end = entitlement.expiresAt;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.gutterSm,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(Icons.check_circle, color: AppColors.secondary),
              Expanded(
                child: Text(
                  UpgradeStrings.activeTitle,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            UpgradeStrings.activePlan(entitlement.plan),
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (end != null)
            Text(
              UpgradeStrings.activeUntil(
                '${end.day} ${ArabicText.month(end)} ${end.year}',
              ),
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          SecondaryButton(
            label: UpgradeStrings.manageSubscription,
            onPressed: onManage,
          ),
        ],
      ),
    );
  }
}
