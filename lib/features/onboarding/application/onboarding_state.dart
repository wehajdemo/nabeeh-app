import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';

enum OnboardingStep {
  salary,
  commitments,
  payday;

  static const int total = 3;

  /// 1-based position, for "step N of 3".
  int get number => index + 1;
  bool get isFirst => this == salary;
  bool get isLast => this == payday;
}

enum OnboardingSaveStatus { idle, saving, failed }

@immutable
class OnboardingState {
  const OnboardingState({
    required this.step,
    required this.netSalary,
    required this.commitments,
    required this.payDay,
    this.saveStatus = OnboardingSaveStatus.idle,
  });

  final OnboardingStep step;
  final Money netSalary;
  final List<CommitmentDraft> commitments;
  final int payDay;
  final OnboardingSaveStatus saveStatus;

  Money get commitmentsTotal =>
      commitments.fold(const Money.zero(), (sum, c) => sum + c.amount);

  bool get isSaving => saveStatus == OnboardingSaveStatus.saving;

  /// The salary is the only required input; the rest has sensible defaults.
  bool get canContinue =>
      !isSaving && (step != OnboardingStep.salary || netSalary.isPositive);

  OnboardingState copyWith({
    OnboardingStep? step,
    Money? netSalary,
    List<CommitmentDraft>? commitments,
    int? payDay,
    OnboardingSaveStatus? saveStatus,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      netSalary: netSalary ?? this.netSalary,
      commitments: commitments ?? this.commitments,
      payDay: payDay ?? this.payDay,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }
}

/// Figures shown in the "smart budget summary" card.
@immutable
class OnboardingSummary {
  const OnboardingSummary({
    required this.netSalary,
    required this.commitmentsTotal,
    required this.dailyLimit,
    required this.daysUntilPayday,
  });

  final Money netSalary;
  final Money commitmentsTotal;
  final Money dailyLimit;
  final int daysUntilPayday;
}
