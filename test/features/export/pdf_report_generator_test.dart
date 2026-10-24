import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/expense.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/export/data/pdf_report_generator.dart';
import 'package:rateby/features/export/domain/budget_report.dart';

import '../../support/fake_file_sharer.dart';
import '../../support/test_overrides.dart';

void main() {
  test('renders an Arabic report as a valid PDF', () async {
    final fonts = await fontsFromDisk();
    final report = BudgetReportBuilder.build(
      profile: BudgetProfile(
        netSalary: Money.fromRiyals(12000),
        payDay: 27,
        commitments: [
          for (var i = 0; i < 60; i++) // enough rows to span several pages
            FixedExpense.scheduled(
              id: 'c$i',
              title: 'التزام رقم $i',
              amount: Money.fromRiyals(10),
              category: FixedExpenseCategory.utilities,
              date: DateTime(2026, 10, 27),
            ),
        ],
      ),
      goals: [
        SavingsGoal(
          id: 'g',
          title: 'رحلة العمرة',
          target: Money.fromRiyals(5000),
          saved: Money.fromRiyals(1200),
          monthlyContribution: Money.fromRiyals(300),
        ),
      ],
      expenses: [
        Expense(
          id: 'e',
          amount: Money.fromRiyals(23),
          createdAt: DateTime(2026, 10, 22, 9),
        ),
      ],
      now: testNow,
    );

    final bytes = await PdfReportGenerator.generate(
      report,
      regularFont: fonts.regular,
      boldFont: fonts.bold,
    );

    expect(looksLikePdf(bytes), isTrue);
    expect(bytes.length, greaterThan(5000));
  });

  test('also works with nothing to list', () async {
    final fonts = await fontsFromDisk();
    final report = BudgetReportBuilder.build(
      profile: BudgetProfile(netSalary: Money.fromRiyals(5000), payDay: 25),
      goals: const [],
      expenses: const [],
      now: testNow,
    );

    final bytes = await PdfReportGenerator.generate(
      report,
      regularFont: fonts.regular,
      boldFont: fonts.bold,
    );

    expect(looksLikePdf(bytes), isTrue);
  });
}
