import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/utils/money_formatter.dart';

void main() {
  group('Money', () {
    test('stores halalas without floating-point drift', () {
      final total = Money.fromRiyals(0.1) + Money.fromRiyals(0.2);
      expect(total.halalas, 30);
      expect(total, Money.fromRiyals(0.3));
    });

    test('parse handles partial keypad input', () {
      expect(Money.parse('12').halalas, 1200);
      expect(Money.parse('12.').halalas, 1200);
      expect(Money.parse('12.5').halalas, 1250);
      expect(Money.parse('0.05').halalas, 5);
      expect(Money.parse('').isZero, isTrue);
    });

    test('fractionOf is clamped to 0..1 and safe for zero totals', () {
      expect(Money.fromRiyals(23).fractionOf(Money.fromRiyals(92)), 0.25);
      expect(Money.fromRiyals(200).fractionOf(Money.fromRiyals(100)), 1.0);
      expect(Money.fromRiyals(5).fractionOf(const Money.zero()), 0.0);
    });

    test('clampNonNegative', () {
      final negative = Money.fromRiyals(1) - Money.fromRiyals(3);
      expect(negative.isNegative, isTrue);
      expect(negative.clampNonNegative().isZero, isTrue);
    });
  });

  group('MoneyFormatter', () {
    test('drops decimals for whole amounts and groups thousands', () {
      expect(MoneyFormatter.format(Money.fromRiyals(1850)), '1,850');
      expect(MoneyFormatter.format(Money.fromRiyals(62)), '62');
    });

    test('keeps two decimals otherwise', () {
      expect(MoneyFormatter.format(Money.fromRiyals(185.5)), '185.50');
      expect(MoneyFormatter.formatExact(Money.fromRiyals(185)), '185.00');
    });
  });
}
