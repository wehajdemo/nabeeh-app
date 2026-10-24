import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/data/budget_storage.dart';
import 'package:rateby/features/budget/data/local_budget_store.dart';
import 'package:rateby/features/budget/data/store_data_codec.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';

import '../../support/test_overrides.dart';

LocalBudgetStore open(BudgetStorage storage) =>
    LocalBudgetStore(clock: () => testNow, storage: storage);

void main() {
  test('data written by one launch is restored by the next', () async {
    final storage = MemoryBudgetStorage();
    final first = open(storage);
    await first.completeSetup(
      BudgetProfile(
        netSalary: Money.fromRiyals(12000),
        payDay: 25,
        commitments: [
          FixedExpense.scheduled(
            id: 'c1',
            title: 'قسط',
            amount: Money.fromRiyals(1850),
            category: FixedExpenseCategory.carFinance,
            date: DateTime(2026, 11, 25),
          ),
        ],
      ),
    );
    await first.addGoal(
      GoalDraft(
        title: 'هدف',
        target: Money.fromRiyals(5000),
        monthlyContribution: Money.fromRiyals(250),
      ),
    );
    await first.logExpense(Money.fromRiyals(12.5));
    await first.saveSettings(
      const AppSettings(enabledPayoutAlertIds: {'gov-salaries'}),
    );

    final second = open(storage);
    final profile = await second.watchProfile().first;
    expect(profile!.netSalary, Money.fromRiyals(12000));
    expect(profile.payDay, 25);
    expect(profile.commitments.single.title, 'قسط');
    expect(profile.commitments.single.date, DateTime(2026, 11, 25));

    final goals = await second.watchGoals().first;
    expect(goals.single.target, Money.fromRiyals(5000));

    final snapshot = await second.watchSnapshot().first;
    expect(snapshot.allowance.spentToday, Money.fromRiyals(12.5));

    final settings = await second.watchSettings().first;
    expect(settings.enabledPayoutAlertIds, {'gov-salaries'});

    // New ids must not collide with restored ones.
    await second.addGoal(
      GoalDraft(
        title: 'آخر',
        target: Money.fromRiyals(1),
        monthlyContribution: const Money.zero(),
      ),
    );
    final ids = (await second.watchGoals().first).map((g) => g.id).toSet();
    expect(ids, hasLength(2));
  });

  test('reset wipes the saved data too', () async {
    final storage = MemoryBudgetStorage();
    final store = open(storage);
    await store.completeSetup(
      BudgetProfile(netSalary: Money.fromRiyals(9000), payDay: 27),
    );
    await store.resetAll();

    expect(await open(storage).watchProfile().first, isNull);
  });

  test('unreadable or foreign data starts fresh instead of crashing', () async {
    for (final raw in ['', 'not json', '{"version": 99}', '{"version": 1}']) {
      final store = open(MemoryBudgetStorage(raw));
      expect(await store.watchProfile().first, isNull, reason: raw);
      expect(await store.watchGoals().first, isEmpty, reason: raw);
    }
  });

  test('codec round-trips every field', () {
    final data = StoreData(
      profile: BudgetProfile(
        netSalary: Money.fromHalalas(1200050),
        payDay: 31,
      ),
      settings: const AppSettings(
        dailyLimitAlerts: false,
        officialPayoutAlerts: false,
        appearance: AppearanceMode.dark,
        enabledPayoutAlertIds: {'b', 'a'},
      ),
      goals: const [],
      ledger: const [],
      nextId: 7,
      lastCreditedPayday: DateTime(2026, 9, 27),
    );
    final decoded = StoreDataCodec.decode(StoreDataCodec.encode(data))!;
    expect(decoded.profile!.netSalary, Money.fromHalalas(1200050));
    expect(decoded.profile!.payDay, 31);
    expect(decoded.settings.dailyLimitAlerts, isFalse);
    expect(decoded.settings.appearance, AppearanceMode.dark);
    expect(decoded.settings.enabledPayoutAlertIds, {'a', 'b'});
    expect(decoded.nextId, 7);
    expect(decoded.lastCreditedPayday, DateTime(2026, 9, 27));
  });

  test('data saved before goal crediting existed still loads', () {
    final withoutField = StoreDataCodec.encode(
      const StoreData(
        profile: null,
        settings: AppSettings(),
        goals: [],
        ledger: [],
        nextId: 0,
      ),
    );
    expect(StoreDataCodec.decode(withoutField)!.lastCreditedPayday, isNull);
  });

  test('data saved with the old dark-mode flag still loads (follows phone)', () {
    final current = jsonDecode(
      StoreDataCodec.encode(
        const StoreData(
          profile: null,
          settings: AppSettings(),
          goals: [],
          ledger: [],
          nextId: 0,
        ),
      ),
    ) as Map<String, dynamic>;
    final settings = (current['settings'] as Map<String, dynamic>)
      ..remove('appearance')
      ..['darkMode'] = false;

    final decoded = StoreDataCodec.decode(jsonEncode(current));
    expect(decoded, isNotNull);
    expect(decoded!.settings.appearance, AppearanceMode.system);
    expect(settings.containsKey('darkMode'), isTrue);
  });
}
