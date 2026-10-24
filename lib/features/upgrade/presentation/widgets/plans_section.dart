import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/presentation/upgrade_strings.dart';
import 'package:rateby/features/upgrade/presentation/widgets/plan_option_card.dart';

/// Yearly vs. monthly selector. Prices are derived from [PlusPlan].
class PlansSection extends StatelessWidget {
  const PlansSection({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final PlusPlanType selected;
  final ValueChanged<PlusPlanType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  UpgradeStrings.plansTitle,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                UpgradeStrings.plansHint,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PlanOptionCard(
          title: UpgradeStrings.yearlyTitle,
          note: UpgradeStrings.yearlyNote(
            MoneyFormatter.format(PlusPlan.yearlyPrice),
          ),
          price: _oneDecimal(PlusPlan.yearlyPerMonth.riyals),
          priceSuffix: UpgradeStrings.perMonth,
          strikePrice: UpgradeStrings.strikePrice(
            MoneyFormatter.format(PlusPlan.monthlyPrice),
          ),
          ribbon: UpgradeStrings.bestValue(PlusPlan.yearlySavingsPercent),
          isSelected: selected == PlusPlanType.yearly,
          onTap: () => onSelected(PlusPlanType.yearly),
        ),
        PlanOptionCard(
          title: UpgradeStrings.monthlyTitle,
          note: UpgradeStrings.monthlyNote,
          price: MoneyFormatter.format(PlusPlan.monthlyPrice),
          priceSuffix: UpgradeStrings.perMonth,
          isSelected: selected == PlusPlanType.monthly,
          onTap: () => onSelected(PlusPlanType.monthly),
        ),
      ],
    );
  }

  /// `5.58` → `5.6` (marketing-style per-month figure).
  static String _oneDecimal(double value) => value.toStringAsFixed(1);
}
