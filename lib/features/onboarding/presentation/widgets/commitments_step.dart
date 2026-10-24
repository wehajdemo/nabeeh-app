import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';
import 'package:rateby/features/budget/presentation/widgets/commitment_form_sheet.dart';
import 'package:rateby/features/budget/presentation/widgets/commitment_tile.dart';
import 'package:rateby/features/onboarding/application/onboarding_controller.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';
import 'package:rateby/features/onboarding/presentation/widgets/step_intro.dart';
import 'package:rateby/features/onboarding/presentation/widgets/upcoming_step_tile.dart';
import 'package:rateby/core/money/money.dart';

/// Step 2 — fixed monthly commitments.
class CommitmentsStep extends ConsumerWidget {
  const CommitmentsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitments = ref.watch(
      onboardingControllerProvider.select((s) => s.commitments),
    );
    final total = ref.watch(
      onboardingControllerProvider.select((s) => s.commitmentsTotal),
    );
    final payDay = ref.watch(
      onboardingControllerProvider.select((s) => s.payDay),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        const StepIntro(
          badgeIcon: Icons.receipt_long,
          badge: OnboardingStrings.commitmentsBadge,
          title: OnboardingStrings.commitmentsTitle,
          subtitle: OnboardingStrings.commitmentsSubtitle,
        ),
        _TotalCard(count: commitments.length, total: total),
        Column(
          spacing: AppSpacing.gutterSm,
          children: [
            for (var i = 0; i < commitments.length; i++)
              CommitmentTile(
                key: ObjectKey(commitments[i]),
                title: commitments[i].title,
                amount: commitments[i].amount,
                category: commitments[i].category,
                onRemove: () => controller.removeCommitmentAt(i),
              ),
            DashedBorderButton(
              label: BudgetStrings.addCommitmentCta,
              onPressed: () async {
                final draft = await showCommitmentFormSheet(context);
                if (draft != null) controller.addCommitment(draft);
              },
            ),
          ],
        ),
        UpcomingStepTile(
          number: 3,
          title: OnboardingStrings.lastStepTitle,
          note: OnboardingStrings.lastStepNote(payDay),
        ),
      ],
    );
  }

}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.count, required this.total});

  final int count;
  final Money total;

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
                    OnboardingStrings.commitmentsTotal,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.hero.onPrimary80,
                    ),
                  ),
                  CurrencyAmount(
                    amount: total,
                    amountStyle: AppTypography.headlineLg.copyWith(
                      color: AppColors.hero.onPrimary,
                    ),
                    symbolStyle: AppTypography.labelMd.copyWith(
                      color: AppColors.hero.onPrimary80,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InfoPill(
                  label: BudgetStrings.commitmentCount(count),
                  background: AppColors.hero.onPrimary15,
                  foreground: AppColors.hero.onPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  OnboardingStrings.autoDeducted,
                  style: AppTypography.labelXs.copyWith(
                    color: AppColors.hero.onPrimary75,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
