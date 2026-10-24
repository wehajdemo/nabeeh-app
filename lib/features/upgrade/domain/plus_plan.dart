import 'package:rateby/core/money/money.dart';

enum PlusPlanType { yearly, monthly }

/// Pricing of "نبيه بلس". Prices include VAT.
abstract final class PlusPlan {
  static final Money monthlyPrice = Money.fromRiyals(9);
  static final Money yearlyPrice = Money.fromRiyals(67);
  static const int trialDays = 7;

  /// What a year of monthly billing would cost.
  static Money get monthlyBilledForYear =>
      Money.fromHalalas(monthlyPrice.halalas * 12);

  /// The yearly plan expressed per month (rounded down to a halala).
  static Money get yearlyPerMonth => Money.fromHalalas(yearlyPrice.halalas ~/ 12);

  /// Whole-percent saving of yearly vs. twelve monthly payments.
  static int get yearlySavingsPercent {
    final full = monthlyBilledForYear.halalas;
    if (full <= 0) return 0;
    return ((full - yearlyPrice.halalas) * 100 / full).round();
  }
}
