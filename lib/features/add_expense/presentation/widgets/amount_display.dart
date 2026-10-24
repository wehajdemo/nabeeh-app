import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/features/add_expense/application/add_expense_view_state.dart';

/// Big amount readout plus the contextual hint line below it.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({required this.view, super.key});

  final AddExpenseViewState view;

  String get _hintText => switch (view.hint) {
        AmountHint.prompt => AppStrings.hintPrompt,
        AmountHint.invalid => AppStrings.hintInvalid,
        AmountHint.deduct =>
          AppStrings.hintDeduct(MoneyFormatter.format(view.hintAmount!)),
        AmountHint.overLimit =>
          AppStrings.hintOverLimit(MoneyFormatter.format(view.hintAmount!)),
      };

  Color get _hintColor => switch (view.hint) {
        AmountHint.prompt => AppColors.onSurfaceVariant,
        AmountHint.deduct => AppColors.secondary,
        AmountHint.overLimit => AppColors.stateWarning,
        AmountHint.invalid => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.cardMd,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Text(
                AppStrings.amountDue,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Digits are always laid out left-to-right: "ر.س 12.50".
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AppStrings.currencySymbol,
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        view.amountText,
                        style: AppTypography.currencyStat.copyWith(
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                liveRegion: true,
                child: Text(
                  _hintText,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: _hintColor,
                    fontWeight: view.hint == AmountHint.prompt
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
