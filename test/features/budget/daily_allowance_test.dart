import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';
import 'package:rateby/features/budget/domain/entities/daily_allowance.dart';

void main() {
  DailyAllowance allowance(num limit, num spent) => DailyAllowance(
        dailyLimit: Money.fromRiyals(limit),
        spentToday: Money.fromRiyals(spent),
      );

  test('matches the numbers in the design (62 of 85, 27% spent)', () {
    final a = allowance(85, 23);
    expect(a.remaining, Money.fromRiyals(62));
    expect(a.spentPercent, 27);
    expect(a.remainingPercent, 73);
    expect(a.health, BudgetHealth.onTrack);
  });

  test('health thresholds', () {
    expect(allowance(100, 79).health, BudgetHealth.onTrack);
    expect(allowance(100, 80).health, BudgetHealth.nearLimit);
    expect(allowance(100, 99).health, BudgetHealth.nearLimit);
    expect(allowance(100, 100).health, BudgetHealth.exceeded);
    expect(allowance(100, 140).health, BudgetHealth.exceeded);
  });

  test('overspending never produces a negative remaining amount', () {
    final a = allowance(100, 140);
    expect(a.remaining.isZero, isTrue);
    expect(a.overspent, Money.fromRiyals(40));
    expect(a.remainingFraction, 0);
  });
}
