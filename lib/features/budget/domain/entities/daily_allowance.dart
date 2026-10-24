import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';

/// What the user may still spend today.
@immutable
class DailyAllowance {
  const DailyAllowance({required this.dailyLimit, required this.spentToday});

  /// Share of the limit that, once spent, flips the state to "near limit".
  static const double nearLimitThreshold = 0.8;

  final Money dailyLimit;
  final Money spentToday;

  Money get remaining => (dailyLimit - spentToday).clampNonNegative();
  Money get overspent => (spentToday - dailyLimit).clampNonNegative();

  /// 0‥1 — how much of the limit is used.
  double get spentFraction => spentToday.fractionOf(dailyLimit);

  /// 0‥1 — how much of the limit is left.
  double get remainingFraction => remaining.fractionOf(dailyLimit);

  /// Whole-number percentages that always add up to 100.
  int get spentPercent => (spentFraction * 100).round();
  int get remainingPercent => 100 - spentPercent;

  BudgetHealth get health {
    if (dailyLimit.isZero) {
      return spentToday.isZero ? BudgetHealth.onTrack : BudgetHealth.exceeded;
    }
    final spent = spentFraction;
    if (spent >= 1) return BudgetHealth.exceeded;
    if (spent >= nearLimitThreshold) return BudgetHealth.nearLimit;
    return BudgetHealth.onTrack;
  }

  @override
  bool operator ==(Object other) =>
      other is DailyAllowance &&
      other.dailyLimit == dailyLimit &&
      other.spentToday == spentToday;

  @override
  int get hashCode => Object.hash(dailyLimit, spentToday);
}
