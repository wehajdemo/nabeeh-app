import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';

/// Days left until the next salary plus how far through the cycle we are.
class SalaryCountdownCard extends StatelessWidget {
  const SalaryCountdownCard({required this.cycle, super.key});

  final SalaryCycle cycle;

  @override
  Widget build(BuildContext context) {
    final title = cycle.isPaydayToday
        ? AppStrings.paydayToday
        : ArabicText.remainingDays(cycle.daysUntilPayday);

    return AppCard(
      shadows: AppShadows.elevated,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconBadge(
                  icon: Icons.event_outlined,
                  background: AppColors.surfaceContainer,
                  foreground: AppColors.primary,
                  size: 48,
                  iconSize: 26,
                  borderRadius: AppRadius.card,
                ),
                const SizedBox(width: AppSpacing.gutterSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.headlineSm.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          InfoPill(
                            label: '${AppStrings.payday} ${cycle.nextPayday.day}',
                            background: AppColors.secondaryContainer30,
                            foreground: AppColors.onSecondaryContainer,
                            textStyle: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppStrings.nextPaydayCaption(
                          ArabicText.month(cycle.nextPayday),
                        ),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RingProgressIndicator(
                value: cycle.progress,
                child: Text(
                  '${MoneyFormatter.percent(cycle.progress)}%',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.ofTheMonth,
                style: AppTypography.labelXs.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
