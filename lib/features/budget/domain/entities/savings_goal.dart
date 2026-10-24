import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';

enum GoalKind { emergency, travel, car, custom }

/// A savings target funded by an automatic monthly deduction.
@immutable
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.title,
    required this.target,
    required this.saved,
    required this.monthlyContribution,
    this.subtitle = '',
    this.kind = GoalKind.custom,
  });

  final String id;
  final String title;
  final String subtitle;
  final GoalKind kind;
  final Money target;
  final Money saved;
  final Money monthlyContribution;

  Money get remaining => (target - saved).clampNonNegative();

  /// What is really set aside each payday: the monthly amount, but never more
  /// than is still missing, and nothing once the goal is complete.
  Money get effectiveMonthly =>
      monthlyContribution <= remaining ? monthlyContribution : remaining;

  /// 0‥1.
  double get progress => saved.fractionOf(target);

  /// Whole percent, rounded **down** so a goal never reads 100% early.
  int get percent => target.isPositive
      ? math.min(100, saved.halalas * 100 ~/ target.halalas)
      : 0;

  bool get isComplete => target.isPositive && saved >= target;

  SavingsGoal copyWith({
    String? title,
    String? subtitle,
    Money? target,
    Money? saved,
    Money? monthlyContribution,
  }) {
    return SavingsGoal(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      kind: kind,
      target: target ?? this.target,
      saved: saved ?? this.saved,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SavingsGoal &&
      other.id == id &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.kind == kind &&
      other.target == target &&
      other.saved == saved &&
      other.monthlyContribution == monthlyContribution;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        subtitle,
        kind,
        target,
        saved,
        monthlyContribution,
      );
}

/// User input for creating or editing a goal.
@immutable
class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.target,
    required this.monthlyContribution,
  });

  final String title;
  final Money target;
  final Money monthlyContribution;
}
