import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/features/budget/presentation/widgets/payday_picker.dart';
import 'package:rateby/features/onboarding/application/onboarding_controller.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';
import 'package:rateby/features/onboarding/presentation/widgets/budget_summary_card.dart';
import 'package:rateby/features/onboarding/presentation/widgets/step_intro.dart';

/// Step 3 — payday plus the resulting budget summary.
class PaydayStep extends ConsumerWidget {
  const PaydayStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payDay = ref.watch(
      onboardingControllerProvider.select((s) => s.payDay),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        const StepIntro(
          badgeIcon: Icons.flag,
          badge: OnboardingStrings.paydayBadge,
          title: OnboardingStrings.paydayTitle,
          subtitle: OnboardingStrings.paydaySubtitle,
        ),
        PaydayPicker(selectedDay: payDay, onSelected: controller.setPayDay),
        const BudgetSummaryCard(),
      ],
    );
  }
}
