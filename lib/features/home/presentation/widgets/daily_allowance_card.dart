import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';
import 'package:rateby/features/budget/domain/entities/daily_allowance.dart';
import 'package:rateby/features/budget/presentation/budget_health_ui.dart';

/// Hero card: the one number that matters — what can I spend today.
class DailyAllowanceCard extends StatelessWidget {
  const DailyAllowanceCard({
    required this.allowance,
    required this.health,
    super.key,
  });

  final DailyAllowance allowance;
  final BudgetHealth health;

  @override
  Widget build(BuildContext context) {
    final limitText =
        '${MoneyFormatter.format(allowance.dailyLimit)} ${AppStrings.currencySymbol}';
    final spentText = AppStrings.spentToday(
      MoneyFormatter.format(allowance.spentToday),
      '${allowance.spentPercent}',
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.elevated,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          children: [
            Positioned(
              left: -40,
              bottom: -40,
              child: _Glow(color: AppColors.hero.secondaryContainer10, size: 176),
            ),
            Positioned(
              right: -32,
              top: -32,
              child: _Glow(color: AppColors.hero.primaryFixed10, size: 144),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 90,
                color: AppColors.hero.onPrimary10,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: AppSpacing.cardLg,
                child: Column(
                  children: [
                    InfoPill(
                      label: health == BudgetHealth.exceeded
                          ? AppStrings.dailyAllowanceOverLimit
                          : AppStrings.dailyAllowanceLabel,
                      icon: Icons.savings_outlined,
                      iconColor: AppColors.hero.secondaryContainer,
                      background: AppColors.hero.onPrimary15,
                      foreground: AppColors.hero.onPrimary,
                    ),
                    AppSpacing.gapSm,
                    CurrencyAmount(
                      amount: allowance.remaining,
                      gap: AppSpacing.sm,
                      amountStyle: AppTypography.displayAmount.copyWith(
                        color: AppColors.hero.onPrimary,
                      ),
                      symbolStyle: AppTypography.headlineMd.copyWith(
                        color: AppColors.hero.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text.rich(
                      TextSpan(
                        text: '${AppStrings.leftOfTodayPrefix} ',
                        children: [
                          TextSpan(
                            text: limitText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.hero.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.hero.onPrimary80,
                      ),
                    ),
                    AppSpacing.gapMd,
                    AppProgressBar(
                      value: allowance.remainingFraction,
                      height: AppSizes.progressHeightLg,
                      inset: 2,
                      trackColor: AppColors.hero.primary40,
                      fill: health.heroProgressGradient,
                    ),
                    AppSpacing.gapSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Dot(
                                color: AppColors.hero.secondaryContainer,
                                size: 6,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  spentText,
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.hero.onPrimary75,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppStrings.remainingPercent('${allowance.remainingPercent}'),
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.hero.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft radial glow used as hero decoration (cheaper than a blur filter).
class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}
