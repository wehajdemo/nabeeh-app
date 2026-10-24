import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/onboarding/application/onboarding_controller.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';

/// Live preview of what the entered numbers mean for daily spending.
class BudgetSummaryCard extends ConsumerWidget {
  const BudgetSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(onboardingSummaryProvider);
    return AppCard(
      padding: AppSpacing.cardMd,
      child: Column(
        spacing: AppSpacing.md,
        children: [
          Row(
            children: [
              IconBadge(
                icon: Icons.query_stats,
                background: AppColors.primaryFixed,
                foreground: AppColors.onPrimaryFixedVariant,
              ),
              const SizedBox(width: AppSpacing.gutterSm),
              Expanded(
                child: Text(
                  OnboardingStrings.summaryTitle,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InfoPill(
                label: OnboardingStrings.summaryReady,
                background: AppColors.stateSafeBackground,
                foreground: AppColors.stateSafe,
                textStyle: AppTypography.labelXs.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            spacing: AppSpacing.gutterSm,
            children: [
              Expanded(
                child: _Figure(
                  label: OnboardingStrings.summarySalary,
                  amount: summary.netSalary,
                ),
              ),
              Expanded(
                child: _Figure(
                  label: OnboardingStrings.summaryCommitments,
                  amount: summary.commitmentsTotal,
                ),
              ),
            ],
          ),
          _DailyLimit(
            amount: summary.dailyLimit,
            daysUntilPayday: summary.daysUntilPayday,
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.amount});

  final String label;
  final Money amount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.cardMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            CurrencyAmount(
              amount: amount,
              amountStyle: AppTypography.labelLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              symbolStyle: AppTypography.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyLimit extends StatelessWidget {
  const _DailyLimit({required this.amount, required this.daysUntilPayday});

  final Money amount;
  final int daysUntilPayday;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.cardMd,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OnboardingStrings.summaryDaily,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.hero.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    OnboardingStrings.untilPayday(daysUntilPayday),
                    style: AppTypography.labelXs.copyWith(
                      color: AppColors.hero.onPrimary75,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              MoneyFormatter.format(amount),
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.hero.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              OnboardingStrings.perDay,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.hero.onPrimary80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
