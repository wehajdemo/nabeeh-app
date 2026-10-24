import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/budget/domain/services/goal_payday_crediting.dart';

SavingsGoal goal({
  String id = 'g',
  num target = 10000,
  num saved = 0,
  num monthly = 500,
}) =>
    SavingsGoal(
      id: id,
      title: id,
      target: Money.fromRiyals(target),
      saved: Money.fromRiyals(saved),
      monthlyContribution: Money.fromRiyals(monthly),
    );

PaydayCredit credit(
  List<SavingsGoal> goals, {
  required DateTime last,
  required DateTime today,
  int payDay = 27,
}) =>
    GoalPaydayCrediting.credit(
      goals: goals,
      lastCredited: last,
      payDay: payDay,
      today: today,
    );

void main() {
  group('latestPayday', () {
    test('is the previous payday before payday, and payday itself on it', () {
      DateTime latest(DateTime today) =>
          GoalPaydayCrediting.latestPayday(payDay: 27, today: today);
      expect(latest(DateTime(2026, 10, 22)), DateTime(2026, 9, 27));
      expect(latest(DateTime(2026, 10, 26)), DateTime(2026, 9, 27));
      expect(latest(DateTime(2026, 10, 27)), DateTime(2026, 10, 27));
      expect(latest(DateTime(2026, 10, 28)), DateTime(2026, 10, 27));
    });
  });

  group('credit', () {
    test('nothing is added before the next payday', () {
      final result = credit(
        [goal()],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 10, 26),
      );
      expect(result.paydays, 0);
      expect(result.goals.single.saved, Money.fromRiyals(0));
      expect(result.lastCredited, DateTime(2026, 9, 27));
    });

    test('one contribution on payday itself', () {
      final result = credit(
        [goal(saved: 1000)],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 10, 27),
      );
      expect(result.paydays, 1);
      expect(result.goals.single.saved, Money.fromRiyals(1500));
      expect(result.lastCredited, DateTime(2026, 10, 27));
    });

    test('catches up every missed payday', () {
      final result = credit(
        [goal()],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 12, 28),
      );
      expect(result.paydays, 3); // 27 Oct, 27 Nov, 27 Dec
      expect(result.goals.single.saved, Money.fromRiyals(1500));
      expect(result.lastCredited, DateTime(2026, 12, 27));
    });

    test('crediting twice for the same day adds nothing the second time', () {
      final first = credit(
        [goal()],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 10, 30),
      );
      final second = credit(
        first.goals,
        last: first.lastCredited,
        today: DateTime(2026, 10, 30),
      );
      expect(second.paydays, 0);
      expect(second.goals.single.saved, first.goals.single.saved);
    });

    test('stops at the target and never overshoots', () {
      final result = credit(
        [goal(target: 1000, saved: 900)],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 12, 28),
      );
      expect(result.goals.single.saved, Money.fromRiyals(1000));
      expect(result.goals.single.isComplete, isTrue);
      expect(result.paydays, 3);
    });

    test('a completed goal is not credited', () {
      final done = goal(target: 1000, saved: 1000);
      expect(done.effectiveMonthly, const Money.zero());
      final result = credit(
        [done],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 10, 28),
      );
      expect(result.goals.single.saved, Money.fromRiyals(1000));
    });

    test('credits every goal independently', () {
      final result = credit(
        [goal(id: 'a', monthly: 500), goal(id: 'b', monthly: 120)],
        last: DateTime(2026, 9, 27),
        today: DateTime(2026, 10, 28),
      );
      expect(result.goals[0].saved, Money.fromRiyals(500));
      expect(result.goals[1].saved, Money.fromRiyals(120));
    });

    test('payday 31 uses the last day of short months', () {
      final result = credit(
        [goal()],
        last: DateTime(2027, 1, 31),
        today: DateTime(2027, 2, 28),
        payDay: 31,
      );
      expect(result.paydays, 1);
      expect(result.lastCredited, DateTime(2027, 2, 28));
    });

    test('is capped after a very long absence', () {
      final result = credit(
        [goal(target: 1000000)],
        last: DateTime(2020, 1, 27),
        today: DateTime(2026, 10, 22),
      );
      expect(result.paydays, GoalPaydayCrediting.maxPaydays);
      expect(result.lastCredited, DateTime(2026, 9, 27));
    });
  });
}
