import 'package:intl/intl.dart';
import 'package:rateby/core/money/money.dart';

/// Formats [Money] with Western digits (per DESIGN.md → "Typography"):
/// `1,850`, `185.50`. The currency symbol (`ر.س`) is rendered separately by
/// `CurrencyAmount` so it can be sized independently.
abstract final class MoneyFormatter {
  static final NumberFormat _whole = NumberFormat('#,##0', 'en');
  static final NumberFormat _fraction = NumberFormat('#,##0.00', 'en');

  /// Whole riyals drop the decimals; otherwise two decimals are shown.
  static String format(Money money) {
    return money.isWhole
        ? _whole.format(money.riyals)
        : _fraction.format(money.riyals);
  }

  /// Always two decimals — used where precision matters (`185.00`).
  static String formatExact(Money money) => _fraction.format(money.riyals);

  /// `73` for 0.73. Rounds to the nearest integer percent.
  static String percent(double fraction) =>
      (fraction * 100).round().clamp(0, 100).toString();
}
