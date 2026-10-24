import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/data/budget_storage.dart';
import 'package:rateby/features/budget/data/local_budget_store.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/application/goals_controller.dart';

import '../../support/test_overrides.dart';

/// A demo store whose clock can be moved.
class Clock {
  DateTime now = testNow;
  DateTime call() => now;
}

Future<Money> saved(LocalBudgetStore store, String id) async =>
    (await store.watchGoals().first).firstWhere((g) => g.id == id).saved;

void main() {
  test('deposit and withdraw change the saved balance', () async {
    final store = LocalBudgetStore.demo(clock: () => testNow, latency: Duration.zero);
    addTearDown(store.dispose);

    await store.deposit('emergency', Money.fromRiyals(500));
    expect(await saved(store, 'emergency'), Money.fromRiyals(5000));

    await store.withdraw('emergency', Money.fromRiyals(200));
    expect(await saved(store, 'emergency'), Money.fromRiyals(4800));

    await store.withdraw('emergency', Money.fromRiyals(99999));
    expect(await saved(store, 'emergency'), const Money.zero());
  });

  test('zero, negative and unknown-goal changes are ignored', () async {
    final store = LocalBudgetStore.demo(clock: () => testNow, latency: Duration.zero);
    addTearDown(store.dispose);

    await store.deposit('emergency', const Money.zero());
    await store.deposit('emergency', Money.fromRiyals(-50));
    await store.withdraw('emergency', Money.fromRiyals(-50));
    await store.deposit('nope', Money.fromRiyals(100));

    expect(await saved(store, 'emergency'), Money.fromRiyals(4500));
  });

  test('payday adds each goal\'s monthly contribution exactly once', () async {
    final clock = Clock();
    final store = LocalBudgetStore.demo(clock: clock.call, latency: Duration.zero);
    addTearDown(store.dispose);

    // Thu 22 Oct: next payday (27 Oct) has not come yet.
    expect(await store.creditDuePaydays(), 0);

    clock.now = DateTime(2026, 10, 27, 9);
    expect(await store.creditDuePaydays(), 1);
    expect(await saved(store, 'emergency'), Money.fromRiyals(5000));
    expect(await saved(store, 'travel'), Money.fromRiyals(3600));
    expect(await saved(store, 'car'), Money.fromRiyals(13000));

    expect(await store.creditDuePaydays(), 0, reason: 'already credited today');
    expect(await saved(store, 'emergency'), Money.fromRiyals(5000));

    clock.now = DateTime(2026, 11, 29);
    expect(await store.creditDuePaydays(), 1);
    expect(await saved(store, 'emergency'), Money.fromRiyals(5500));
  });

  test('a completed goal stops lowering the daily limit', () async {
    final store = LocalBudgetStore.demo(clock: () => testNow, latency: Duration.zero);
    addTearDown(store.dispose);
    final before = (await store.watchSnapshot().first).allowance.dailyLimit;
    expect(before, Money.fromRiyals(221));

    // Complete the travel goal (target 5,000; its monthly 400 no longer applies).
    await store.deposit('travel', Money.fromRiyals(1800));

    final after = (await store.watchSnapshot().first).allowance.dailyLimit;
    expect(after > before, isTrue);
  });

  test('finishing set-up or changing payday never credits retroactively',
      () async {
    final clock = Clock()..now = DateTime(2026, 10, 30);
    final store = LocalBudgetStore(clock: clock.call);
    addTearDown(store.dispose);
    await store.completeSetup(
      BudgetProfile(netSalary: Money.fromRiyals(10000), payDay: 27),
    );
    await store.addGoal(
      GoalDraft(
        title: 'g',
        target: Money.fromRiyals(5000),
        monthlyContribution: Money.fromRiyals(300),
      ),
    );
    expect(await store.creditDuePaydays(), 0);

    await store.updatePayDay(10);
    expect(await store.creditDuePaydays(), 0);
    expect((await store.watchGoals().first).single.saved, const Money.zero());

    clock.now = DateTime(2026, 11, 10);
    expect(await store.creditDuePaydays(), 1);
    expect((await store.watchGoals().first).single.saved, Money.fromRiyals(300));
  });

  test('credited balances and the last credited payday survive a restart',
      () async {
    final clock = Clock();
    final storage = MemoryBudgetStorage();
    final first = LocalBudgetStore(clock: clock.call, storage: storage);
    await first.completeSetup(
      BudgetProfile(netSalary: Money.fromRiyals(10000), payDay: 27),
    );
    await first.addGoal(
      GoalDraft(
        title: 'g',
        target: Money.fromRiyals(5000),
        monthlyContribution: Money.fromRiyals(300),
      ),
    );
    clock.now = DateTime(2026, 10, 28);
    expect(await first.creditDuePaydays(), 1);
    first.dispose();

    final second = LocalBudgetStore(clock: clock.call, storage: storage);
    addTearDown(second.dispose);
    expect((await second.watchGoals().first).single.saved, Money.fromRiyals(300));
    expect(await second.creditDuePaydays(), 0);
  });

  test('the controller exposes deposit / withdraw / credit', () async {
    final container = ProviderContainer(overrides: [fixedClock(), demoStore()]);
    addTearDown(container.dispose);
    container.listen(goalsControllerProvider, (_, __) {});
    await container.read(goalsControllerProvider.future);
    final controller = container.read(goalsControllerProvider.notifier);

    await controller.deposit('travel', Money.fromRiyals(100));
    await settle();
    final state = await container.read(goalsControllerProvider.future);

    expect(
      state.goals.firstWhere((g) => g.id == 'travel').saved,
      Money.fromRiyals(3300),
    );
    expect(await controller.creditDuePaydays(), 0);
    expect(container.read(goalsRepositoryProvider), isNotNull);
  });
}
