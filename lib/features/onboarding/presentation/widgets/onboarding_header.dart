import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/onboarding/application/onboarding_state.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';

/// Brand row with an optional back button and the "step N of 3" pill,
/// followed by the segmented progress bar.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    required this.step,
    required this.onBack,
    super.key,
  });

  final OnboardingStep step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.gutterSm,
      children: [
        SizedBox(
          height: AppSizes.topBarHeight - AppSpacing.md,
          child: Row(
            children: [
              if (!step.isFirst)
                IconButton(
                  onPressed: onBack,
                  tooltip: OnboardingStrings.back,
                  // Mirrors automatically in RTL: points to the reading start.
                  icon: Icon(Icons.arrow_back, color: AppColors.primary),
                ),
              const BrandAvatar(size: 32),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.appName,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              InfoPill(
                label: OnboardingStrings.stepOf(
                  step.number,
                  OnboardingStep.total,
                ),
                background: AppColors.surfaceContainer,
                foreground: AppColors.onSurfaceVariant,
                textStyle: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        StepProgressBar(current: step.number, total: OnboardingStep.total),
      ],
    );
  }
}
