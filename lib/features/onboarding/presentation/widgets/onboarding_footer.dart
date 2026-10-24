import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/onboarding/application/onboarding_state.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';

/// Privacy note and the primary call to action for the current step.
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    required this.step,
    required this.canContinue,
    required this.isSaving,
    required this.onContinue,
    super.key,
  });

  final OnboardingStep step;
  final bool canContinue;
  final bool isSaving;
  final VoidCallback onContinue;

  String get _label => isSaving
      ? OnboardingStrings.saving
      : switch (step) {
          OnboardingStep.salary => OnboardingStrings.continueNext,
          OnboardingStep.commitments => OnboardingStrings.continueLast,
          OnboardingStep.payday => OnboardingStrings.start,
        };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surfaceContainer)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.gutterSm,
          children: [
            PrimaryButton(
              label: _label,
              icon: step.isLast ? null : Icons.arrow_forward,
              iconAtEnd: true,
              isLoading: isSaving,
              onPressed: canContinue ? onContinue : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: AppColors.outline),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  OnboardingStrings.privacyNote,
                  style: AppTypography.labelXs.copyWith(
                    color: AppColors.outline,
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
