import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/services/daily_limit_calculator.dart';

void main() {
  Money limit({
    required num salary,
    num commitments = 0,
    num goals = 0,
    required int days,
  }) {
    return DailyLimitCalculator.calculate(
      netSalary: Money.fromRiyals(salary),
      commitmentsTotal: Money.fromRiyals(commitments),
      monthlyGoalsTotal: Money.fromRiyals(goals),
      cycleLengthDays: days,
    );
  }

  test('spreads what is left after commitments evenly over the cycle', () {
    expect(limit(salary: 12000, commitments: 3450, days: 30),
        Money.fromRiyals(285));
  });

  test('goal deductions reduce the daily limit', () {
    expect(
      limit(salary: 12000, commitments: 3450, goals: 1900, days: 30),
      Money.fromRiyals(221), // 6,650 ÷ 30 = 221.67 → 221
    );
  });

  test('rounds down to whole riyals so the limit is never optimistic', () {
    expect(limit(salary: 10000, days: 3), Money.fromRiyals(3333));
  });

  test('commitments above the salary give a zero limit, never negative', () {
    expect(limit(salary: 1000, commitments: 3000, days: 30), const Money.zero());
  });

  test('an empty cycle gives zero instead of dividing by zero', () {
    expect(limit(salary: 12000, days: 0), const Money.zero());
  });
}
