import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/application/goals_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';

import '../../support/test_overrides.dart';

ProviderContainer makeContainer({bool plus = true}) {
  final container = ProviderContainer(
    overrides: [fixedClock(), demoStore(), if (plus) plusActive()],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('totals match the design (19,700 of 45,000 — 43%)', () async {
    final container = makeContainer();
    container.listen(goalsControllerProvider, (_, __) {});
    await pumpEventQueue(); // let the store's change stream reach the provider
    final state = await container.read(goalsControllerProvider.future);

    expect(state.totalSaved, Money.fromRiyals(19700));
    expect(state.totalTarget, Money.fromRiyals(45000));
    expect(state.remaining, Money.fromRiyals(25300));
    expect(state.monthlyDeductions, Money.fromRiyals(1900));
    expect(state.achievementPercent, 43);
    expect(state.activeCount, 3);
    expect(state.payDay, 27);
  });

  test('a goal never reads 100% before it is complete', () {
    final almost = SavingsGoal(
      id: 'g',
      title: 'x',
      target: Money.fromRiyals(1000),
      saved: Money.fromRiyals(999),
      monthlyContribution: const Money.zero(),
    );
    expect(almost.percent, 99);
    expect(almost.isComplete, isFalse);
    expect(almost.copyWith(saved: Money.fromRiyals(1000)).percent, 100);
  });

  test('adding a goal updates the totals and lowers the daily limit', () async {
    final container = makeContainer();
    container.listen(goalsControllerProvider, (_, __) {});
    container.listen(budgetSnapshotProvider, (_, __) {});
    final before = await container.read(budgetSnapshotProvider.future);
    expect(before.allowance.dailyLimit, Money.fromRiyals(221));

    await container.read(goalsControllerProvider.notifier).addGoal(
          GoalDraft(
            title: 'رحلة العمرة',
            target: Money.fromRiyals(6000),
            monthlyContribution: Money.fromRiyals(600),
          ),
        );

    await pumpEventQueue(); // let the store's change stream reach the provider
    final state = await container.read(goalsControllerProvider.future);
    expect(state.goals, hasLength(4));
    expect(state.monthlyDeductions, Money.fromRiyals(2500));

    // (12,000 − 3,450 − 2,500) ÷ 30 = 6,050 ÷ 30 = 201.67 → 201
    final after = await container.read(budgetSnapshotProvider.future);
    expect(after.allowance.dailyLimit, Money.fromRiyals(201));
  });

  test('a free user cannot add a goal past the free limit', () async {
    final container = makeContainer(plus: false);
    container.listen(goalsControllerProvider, (_, __) {});
    await container.read(goalsControllerProvider.future);
    final controller = container.read(goalsControllerProvider.notifier);

    // The demo data already holds the 3 goals a free account allows.
    expect(controller.canAddGoal(3), isFalse);
    expect(
      () => controller.addGoal(
        GoalDraft(
          title: 'سيارة',
          target: Money.fromRiyals(50000),
          monthlyContribution: Money.fromRiyals(500),
        ),
      ),
      throwsA(
        isA<PlusRequiredException>().having(
          (e) => e.feature,
          'feature',
          PlusFeature.unlimitedGoals,
        ),
      ),
    );
    await pumpEventQueue(); // let the store's change stream reach the provider
    final state = await container.read(goalsControllerProvider.future);
    expect(state.goals, hasLength(3));
  });

  test('free users can still add goals below the limit, Plus is unlimited',
      () async {
    final free = makeContainer(plus: false);
    expect(free.read(goalsControllerProvider.notifier).canAddGoal(2), isTrue);

    final plus = makeContainer();
    expect(plus.read(goalsControllerProvider.notifier).canAddGoal(50), isTrue);
  });

  test('editing a goal changes its fields but keeps what was saved', () async {
    final container = makeContainer();
    container.listen(goalsControllerProvider, (_, __) {});
    await container.read(goalsControllerProvider.future);

    await container.read(goalsControllerProvider.notifier).updateGoal(
          'travel',
          GoalDraft(
            title: 'سفرة الصيف',
            target: Money.fromRiyals(6000),
            monthlyContribution: Money.fromRiyals(500),
          ),
        );

    await pumpEventQueue(); // let the store's change stream reach the provider
    final state = await container.read(goalsControllerProvider.future);
    final travel = state.goals.firstWhere((g) => g.id == 'travel');
    expect(travel.title, 'سفرة الصيف');
    expect(travel.target, Money.fromRiyals(6000));
    expect(travel.saved, Money.fromRiyals(3200));
  });
}
