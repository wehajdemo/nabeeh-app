import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/expense.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/export/domain/budget_report.dart';
import 'package:rateby/features/export/domain/csv_builder.dart';

import '../../support/test_overrides.dart';

Expense expense(String id, num riyals, DateTime at) =>
    Expense(id: id, amount: Money.fromRiyals(riyals), createdAt: at);

final profile = BudgetProfile(
  netSalary: Money.fromRiyals(12000),
  payDay: 27,
  commitments: [
    FixedExpense.scheduled(
      id: 'c1',
      title: 'قسط السيارة',
      amount: Money.fromRiyals(1850),
      category: FixedExpenseCategory.carFinance,
      date: DateTime(2026, 10, 27),
    ),
    FixedExpense.scheduled(
      id: 'c2',
      title: 'الكهرباء',
      amount: Money.fromRiyals(980),
      category: FixedExpenseCategory.utilities,
      date: DateTime(2026, 10, 27),
    ),
  ],
);

final goals = [
  SavingsGoal(
    id: 'g1',
    title: 'طوارئ',
    target: Money.fromRiyals(10000),
    saved: Money.fromRiyals(4500),
    monthlyContribution: Money.fromRiyals(500),
  ),
];

BudgetReport build(List<Expense> expenses) => BudgetReportBuilder.build(
      profile: profile,
      goals: goals,
      expenses: expenses,
      now: testNow,
    );

void main() {
  final expenses = [
    expense('old', 99, DateTime(2026, 9, 26, 23, 59)), // previous cycle
    expense('first', 40, DateTime(2026, 9, 27, 8)), // cycle start day
    expense('a', 12.5, DateTime(2026, 10, 20, 14, 30)),
    expense('b', 7.5, DateTime(2026, 10, 20, 19)),
    expense('today', 23, DateTime(2026, 10, 22, 9)),
    expense('next', 500, DateTime(2026, 10, 27, 1)), // next cycle
  ];

  test('uses the current salary cycle', () {
    final r = build(expenses);
    expect(r.cycleStart, DateTime(2026, 9, 27));
    expect(r.cycleEnd, DateTime(2026, 10, 27));
  });

  test('only expenses of this cycle are counted, oldest first', () {
    final r = build(expenses);
    expect(r.expenses.map((e) => e.id), ['first', 'a', 'b', 'today']);
    expect(r.spentInCycle, Money.fromRiyals(83)); // 40 + 12.5 + 7.5 + 23
    expect(r.spentToday, Money.fromRiyals(23));
  });

  test('groups spending by day, newest first', () {
    final days = build(expenses).days;
    expect(days.map((d) => d.date), [
      DateTime(2026, 10, 22),
      DateTime(2026, 10, 20),
      DateTime(2026, 9, 27),
    ]);
    expect(days[1].total, Money.fromRiyals(20));
    expect(days[1].count, 2);
  });

  test('summary numbers follow the budget rules', () {
    final r = build(expenses);
    expect(r.commitmentsTotal, Money.fromRiyals(2830));
    expect(r.goalsMonthlyTotal, Money.fromRiyals(500));
    expect(r.freeToSpend, Money.fromRiyals(8670));
    expect(r.remainingInCycle, Money.fromRiyals(8587));
    // (12,000 − 2,830 − 500) ÷ 30 days = 289.
    expect(r.dailyLimit, Money.fromRiyals(289));
    expect(r.goals.single.percent, 45);
    expect(r.goals.single.monthly, Money.fromRiyals(500));
  });

  test('an empty ledger gives an empty report, not an error', () {
    final r = build(const []);
    expect(r.expenses, isEmpty);
    expect(r.days, isEmpty);
    expect(r.spentInCycle, const Money.zero());
  });

  group('CSV', () {
    test('has a BOM, Arabic header and one row per expense', () {
      final csv = ExpensesCsv.build(build(expenses));
      expect(csv.startsWith('\uFEFF'), isTrue);
      // `trim()` would also strip the BOM, so split manually.
      final lines = csv.split('\r\n')..removeLast();
      expect(lines.first, '\uFEFFالتاريخ,الوقت,المبلغ (ر.س),البيان');
      expect(lines.length, 5);
      expect(lines[2], '2026-10-20,14:30,12.50,');
      expect(lines[4], '2026-10-22,09:00,23.00,');
    });

    test('amounts have no thousands separator (safe for CSV)', () {
      final big = [expense('x', 1234.5, DateTime(2026, 10, 1, 10))];
      final csv = ExpensesCsv.build(build(big));
      expect(csv, contains('2026-10-01,10:00,1234.50,'));
    });

    test('an empty ledger still produces the header', () {
      final csv = ExpensesCsv.build(build(const []));
      expect(csv.trim().split('\r\n'), hasLength(1));
    });
  });
}
