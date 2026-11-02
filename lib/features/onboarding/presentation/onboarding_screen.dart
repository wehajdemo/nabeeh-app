import 'package:flutter/material.dart';
import 'package:rateby/features/account/presentation/account_strings.dart';
import 'package:rateby/features/account/presentation/sign_in_prompt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/features/onboarding/application/onboarding_controller.dart';
import 'package:rateby/features/onboarding/application/onboarding_state.dart';
import 'package:rateby/features/onboarding/presentation/onboarding_strings.dart';
import 'package:rateby/features/onboarding/presentation/widgets/commitments_step.dart';
import 'package:rateby/features/onboarding/presentation/widgets/onboarding_footer.dart';
import 'package:rateby/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:rateby/features/onboarding/presentation/widgets/payday_step.dart';
import 'package:rateby/features/onboarding/presentation/widgets/salary_step.dart';

/// First-run wizard: salary → commitments → payday.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingControllerProvider.select((s) => s.step));
    final canContinue = ref.watch(
      onboardingControllerProvider.select((s) => s.canContinue),
    );
    final isSaving = ref.watch(
      onboardingControllerProvider.select((s) => s.isSaving),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    ref.listen(
      onboardingControllerProvider.select((s) => s.saveStatus),
      (_, status) {
        if (status == OnboardingSaveStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(OnboardingStrings.saveFailed)),
          );
        }
      },
    );

    return PopScope(
      // The system back button walks back through the wizard.
      canPop: step.isFirst,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.margin,
                    ),
                    child: OnboardingHeader(step: step, onBack: controller.back),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.margin),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(step),
                          child: switch (step) {
                            OnboardingStep.salary => const SalaryStep(),
                            OnboardingStep.commitments =>
                              const CommitmentsStep(),
                            OnboardingStep.payday => const PaydayStep(),
                          },
                        ),
                      ),
                    ),
                  ),
                  if (step.isFirst)
                    TextButton(
                      onPressed: () => ensureSignedIn(
                        context,
                        ref,
                        reason: SignInReason.restore,
                      ),
                      child: const Text(AccountStrings.haveAccount),
                    ),
                  OnboardingFooter(
                    step: step,
                    canContinue: canContinue,
                    isSaving: isSaving,
                    onContinue:
                        step.isLast ? controller.complete : controller.next,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
