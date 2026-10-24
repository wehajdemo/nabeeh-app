import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// "الحد المتبقي لليوم  185.00 ر.س" with a thin progress bar underneath.
class RemainingLimitStrip extends StatelessWidget {
  const RemainingLimitStrip({
    required this.remaining,
    required this.fraction,
    super.key,
  });

  final Money? remaining;

  /// 0‥1 share of the daily limit left (after the pending expense).
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTypography.labelLg.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w700,
    );

    return AppCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        children: [
          Row(
            children: [
              Dot(color: AppColors.secondaryFixedDim, size: 10),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.remainingToday,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              if (remaining == null)
                Text('—', style: valueStyle)
              else
                CurrencyAmount(
                  amount: remaining!,
                  exactDecimals: true,
                  amountStyle: valueStyle,
                  symbolStyle: valueStyle,
                ),
            ],
          ),
          AppSpacing.gapSm,
          AppProgressBar(value: fraction),
        ],
      ),
    );
  }
}
