import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// "المبالغ الشائعة" — one-tap preset amounts.
class QuickAmountChips extends StatelessWidget {
  const QuickAmountChips({
    required this.amounts,
    required this.onSelected,
    super.key,
  });

  final List<int> amounts;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.commonAmounts,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              AppStrings.oneTap,
              style: AppTypography.labelSm.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        AppSpacing.gapSm,
        Row(
          spacing: AppSpacing.gutterSm,
          children: [
            for (final amount in amounts)
              Expanded(
                child: _QuickAmountChip(
                  amount: amount,
                  onTap: () => onSelected(amount),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({required this.amount, required this.onTap});

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            height: AppSizes.quickChipHeight,
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: '$amount ',
                  children: [
                    TextSpan(
                      text: AppStrings.currencySymbol,
                      style: AppTypography.labelXs.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
