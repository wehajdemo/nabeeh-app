import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';
import 'package:rateby/features/budget/domain/services/daily_limit_calculator.dart';
import 'package:rateby/features/onboarding/application/onboarding_state.dart';

/// Drives the three-step first-run wizard. The UI only reads [state] and
/// calls these methods; nothing here depends on widgets.
class OnboardingController extends AutoDisposeNotifier<OnboardingState> {
  /// Example commitments from the design, editable by the user.
  static final List<CommitmentDraft> _starterCommitments = [
    CommitmentDraft(
      title: 'قسط تمويل السيارة',
      amount: Money.fromRiyals(1850),
      category: FixedExpenseCategory.carFinance,
    ),
    CommitmentDraft(
      title: 'أقساط تابي وتمارا',
      amount: Money.fromRiyals(620),
      category: FixedExpenseCategory.buyNowPayLater,
    ),
    CommitmentDraft(
      title: 'الفواتير والإنترنت',
      amount: Money.fromRiyals(980),
      category: FixedExpenseCategory.utilities,
    ),
  ];

  @override
  OnboardingState build() {
    return OnboardingState(
      step: OnboardingStep.salary,
      netSalary: const Money.zero(),
      commitments: _starterCommitments,
      payDay: BudgetProfile.defaultPayDay,
    );
  }

  void setSalary(Money value) => state = state.copyWith(netSalary: value);

  void setPayDay(int day) => state = state.copyWith(payDay: day.clamp(1, 31).toInt());

  void addCommitment(CommitmentDraft draft) {
    state = state.copyWith(commitments: [...state.commitments, draft]);
  }

  void removeCommitmentAt(int index) {
    if (index < 0 || index >= state.commitments.length) return;
    final next = [...state.commitments]..removeAt(index);
    state = state.copyWith(commitments: next);
  }

  void next() {
    if (!state.canContinue || state.step.isLast) return;
    state = state.copyWith(step: OnboardingStep.values[state.step.index + 1]);
  }

  void back() {
    if (state.step.isFirst || state.isSaving) return;
    state = state.copyWith(step: OnboardingStep.values[state.step.index - 1]);
  }

  /// Persists the profile; the app gate then swaps the wizard for the shell.
  Future<void> complete() async {
    if (!state.canContinue || !state.step.isLast) return;
    state = state.copyWith(saveStatus: OnboardingSaveStatus.saving);

    final today = ref.read(clockProvider)();
    final cycle = SalaryCycle.forPayDay(payDay: state.payDay, today: today);
    final profile = BudgetProfile(
      netSalary: state.netSalary,
      payDay: state.payDay,
      commitments: [
        for (var i = 0; i < state.commitments.length; i++)
          FixedExpense.scheduled(
            id: 'setup-$i',
            title: state.commitments[i].title,
            amount: state.commitments[i].amount,
            category: state.commitments[i].category,
            date: cycle.nextPayday,
          ),
      ],
    );

    try {
      await ref.read(profileRepositoryProvider).completeSetup(profile);
    } catch (_) {
      state = state.copyWith(saveStatus: OnboardingSaveStatus.failed);
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider.autoDispose<OnboardingController, OnboardingState>(
  OnboardingController.new,
);

/// Live preview of the daily limit the user will get.
final onboardingSummaryProvider = Provider.autoDispose<OnboardingSummary>((ref) {
  final s = ref.watch(onboardingControllerProvider);
  final today = ref.watch(clockProvider)();
  final cycle = SalaryCycle.forPayDay(payDay: s.payDay, today: today);
  return OnboardingSummary(
    netSalary: s.netSalary,
    commitmentsTotal: s.commitmentsTotal,
    dailyLimit: DailyLimitCalculator.calculate(
      netSalary: s.netSalary,
      commitmentsTotal: s.commitmentsTotal,
      monthlyGoalsTotal: const Money.zero(),
      cycleLengthDays: cycle.lengthInDays,
    ),
    daysUntilPayday: cycle.daysUntilPayday,
  );
});
