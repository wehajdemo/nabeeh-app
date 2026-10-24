import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/presentation/widgets/salary_input_field.dart';
import 'package:rateby/features/onboarding/application/onboarding_controller.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';
import 'package:rateby/features/onboarding/presentation/widgets/step_intro.dart';
import 'package:rateby/features/onboarding/presentation/widgets/upcoming_step_tile.dart';

/// Step 1 — net monthly salary.
class SalaryStep extends ConsumerWidget {
  const SalaryStep({super.key});

  static const List<int> _presets = [8000, 12000, 15000, 20000];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salary = ref.watch(
      onboardingControllerProvider.select((s) => s.netSalary),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        const StepIntro(
          badgeIcon: Icons.auto_awesome,
          badge: OnboardingStrings.salaryBadge,
          title: OnboardingStrings.salaryTitle,
          subtitle: OnboardingStrings.salarySubtitle,
        ),
        AppCard(
          padding: AppSpacing.cardMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.gutterSm,
            children: [
              Text(
                OnboardingStrings.salaryFieldLabel,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SalaryInputField(value: salary, onChanged: controller.setSalary),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final amount in _presets)
                    _PresetChip(
                      amount: amount,
                      isLast: amount == _presets.last,
                      isSelected: salary == Money.fromRiyals(amount),
                      onTap: () => controller.setSalary(Money.fromRiyals(amount)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Column(
          spacing: AppSpacing.gutterSm,
          children: [
            UpcomingStepTile(
              number: 2,
              title: OnboardingStrings.nextCommitmentsTitle,
              note: OnboardingStrings.nextCommitmentsNote,
            ),
            UpcomingStepTile(
              number: 3,
              title: OnboardingStrings.nextPaydayTitle,
              note: OnboardingStrings.nextPaydayNote,
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.amount,
    required this.isLast,
    required this.isSelected,
    required this.onTap,
  });

  final int amount;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = '${isLast ? '+' : ''}${_group(amount)}';
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.pill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pill,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                widthFactor: 1,
                child: Text(
                  text,
                  style: AppTypography.labelMd.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _group(int n) {
    final s = n.toString();
    return s.length <= 3 ? s : '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}
