import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/budget/domain/entities/salary_cycle.dart';

void main() {
  SalaryCycle cycle(int payDay, DateTime today) =>
      SalaryCycle.forPayDay(payDay: payDay, today: today);

  test('mid-cycle: 5 days before payday on the 27th', () {
    final c = cycle(27, DateTime(2026, 10, 22, 17, 30));
    expect(c.previousPayday, DateTime(2026, 9, 27));
    expect(c.nextPayday, DateTime(2026, 10, 27));
    expect(c.daysUntilPayday, 5);
    expect(c.lengthInDays, 30);
    expect(c.progress, closeTo(25 / 30, 1e-9));
  });

  test('on payday the countdown is zero', () {
    final c = cycle(27, DateTime(2026, 10, 27));
    expect(c.daysUntilPayday, 0);
    expect(c.isPaydayToday, isTrue);
  });

  test('the day after payday points at next month', () {
    final c = cycle(27, DateTime(2026, 10, 28));
    expect(c.nextPayday, DateTime(2026, 11, 27));
    expect(c.daysUntilPayday, 30);
  });

  test('rolls over the year boundary in both directions', () {
    final december = cycle(27, DateTime(2026, 12, 30));
    expect(december.previousPayday, DateTime(2026, 12, 27));
    expect(december.nextPayday, DateTime(2027, 1, 27));

    final january = cycle(27, DateTime(2027, 1, 5));
    expect(january.previousPayday, DateTime(2026, 12, 27));
    expect(january.nextPayday, DateTime(2027, 1, 27));
  });

  test('payday 31 is clamped in short months', () {
    final c = cycle(31, DateTime(2027, 2, 10));
    expect(c.nextPayday, DateTime(2027, 2, 28));
    expect(c.previousPayday, DateTime(2027, 1, 31));
    expect(c.daysUntilPayday, 18);
  });
}
