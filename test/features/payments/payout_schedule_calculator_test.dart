import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/payments/domain/payout_catalog.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/domain/payout_schedule_calculator.dart';

PayoutProgram program(String id) =>
    PayoutCatalog.programs.firstWhere((p) => p.id == id);

PayoutInfo evaluate(String id, DateTime now) =>
    PayoutScheduleCalculator.evaluate(program(id), now);

void main() {
  // Calendar for the tests: 22 Oct 2026 is a Thursday.
  final thursday = DateTime(2026, 10, 22, 17);

  group('weekend rule', () {
    test('Friday moves back to Thursday', () {
      expect(
        PayoutScheduleCalculator.applyWeekendRule(DateTime(2026, 10, 23)),
        DateTime(2026, 10, 22),
      );
    });

    test('Saturday moves forward to Sunday', () {
      expect(
        PayoutScheduleCalculator.applyWeekendRule(DateTime(2026, 10, 24)),
        DateTime(2026, 10, 25),
      );
    });

    test('working days are untouched', () {
      for (final day in [22, 25, 26, 27, 28]) {
        final date = DateTime(2026, 10, day);
        expect(PayoutScheduleCalculator.applyWeekendRule(date), date);
      }
    });
  });

  group('government salaries (27th)', () {
    test('counts down to the 27th and shows progress through the cycle', () {
      final info = evaluate('gov-salaries', thursday);
      expect(info.status, PayoutStatus.confirmed);
      expect(info.nextPayout, DateTime(2026, 10, 27));
      expect(info.lastPayout, DateTime(2026, 9, 27));
      expect(info.daysUntilNext, 5);
      expect(info.wasShiftedForWeekend, isFalse);
      expect(info.cycleProgress, closeTo(25 / 30, 1e-9));
    });

    test('arrives today on payday', () {
      final info = evaluate('gov-salaries', DateTime(2026, 10, 27, 9));
      expect(info.isToday, isTrue);
      expect(info.status, PayoutStatus.confirmed);
    });

    test('rolls to next month once paid (27 Nov is a Friday → Thursday)', () {
      final info = evaluate('gov-salaries', DateTime(2026, 10, 28));
      expect(info.status, PayoutStatus.paid);
      expect(info.lastPayout, DateTime(2026, 10, 27));
      expect(info.nextPayout, DateTime(2026, 11, 26));
      expect(info.wasShiftedForWeekend, isTrue);
    });
  });

  group('citizen account (10th)', () {
    test('10 Oct 2026 is a Saturday → paid on Sunday 11th, shown as paid', () {
      final info = evaluate('citizen-account', thursday);
      expect(info.lastPayout, DateTime(2026, 10, 11));
      expect(info.status, PayoutStatus.paid);
      expect(info.nextPayout, DateTime(2026, 11, 10));
      expect(info.daysUntilNext, 19);
    });
  });

  group('first of the month programs', () {
    test('not "recently paid" three weeks after the 1st', () {
      final info = evaluate('social-security', thursday);
      expect(info.lastPayout, DateTime(2026, 10, 1));
      expect(info.status, PayoutStatus.confirmed);
      expect(info.nextPayout, DateTime(2026, 11, 1));
      expect(info.daysUntilNext, 10);
    });

    test('pensions stay "expected" because the date is not guaranteed', () {
      expect(evaluate('retirees', thursday).status, PayoutStatus.expected);
    });
  });

  test('a payout on a Friday is brought forward and flagged', () {
    const friday23 = PayoutProgram(
      id: 'x',
      kind: PayoutKind.governmentSalary,
      category: PayoutCategory.government,
      title: 'x',
      provider: 'x',
      certainty: PayoutCertainty.confirmed,
      dayOfMonth: 23,
    );
    final info = PayoutScheduleCalculator.evaluate(
      friday23,
      DateTime(2026, 10, 20),
    );
    expect(info.nextPayout, DateTime(2026, 10, 22)); // Thursday
    expect(info.wasShiftedForWeekend, isTrue);
  });

  group('student stipends (window 25–28)', () {
    test('before the window: counts days to its start and end', () {
      final info = evaluate('student-stipends', thursday);
      expect(info.isWindow, isTrue);
      expect(info.nextPayout, DateTime(2026, 10, 25));
      expect(info.windowEnd, DateTime(2026, 10, 28));
      expect(info.daysUntilNext, 3);
      expect(info.daysUntilWindowEnd, 6);
    });

    test('inside the window the start counts as 0 days', () {
      final info = evaluate('student-stipends', DateTime(2026, 10, 26));
      expect(info.daysUntilNext, 0);
      expect(info.daysUntilWindowEnd, 2);
    });

    test('after the window it points at next month', () {
      final info = evaluate('student-stipends', DateTime(2026, 10, 29));
      expect(info.nextPayout, DateTime(2026, 11, 25));
      expect(info.windowEnd, DateTime(2026, 11, 28));
    });
  });

  test('handles year rollover (1 Jan 2027 is a Friday → Thu 31 Dec)', () {
    final info = evaluate('social-security', DateTime(2026, 12, 20));
    expect(info.nextPayout, DateTime(2026, 12, 31));
    expect(info.wasShiftedForWeekend, isTrue);
  });
}
