import 'package:flutter/foundation.dart';

/// Saudi riyal amount stored as an integer number of halalas (1 SAR = 100).
///
/// Integer storage avoids floating-point drift when summing expenses.
@immutable
class Money implements Comparable<Money> {
  const Money._(this.halalas);

  /// Zero riyals.
  const Money.zero() : halalas = 0;

  factory Money.fromHalalas(int halalas) => Money._(halalas);

  /// Rounds to the nearest halala.
  factory Money.fromRiyals(num riyals) => Money._((riyals * 100).round());

  /// Parses user input such as `12`, `12.`, `12.5`, `12.50`. Returns zero for
  /// anything unparsable.
  factory Money.parse(String text) {
    // `12.` is valid keypad input mid-typing but not parsed uniformly
    // across Dart platforms, so drop a dangling decimal point first.
    final normalized =
        text.endsWith('.') ? text.substring(0, text.length - 1) : text;
    final parsed = double.tryParse(normalized);
    return parsed == null ? const Money.zero() : Money.fromRiyals(parsed);
  }

  final int halalas;

  double get riyals => halalas / 100;
  bool get isZero => halalas == 0;
  bool get isNegative => halalas < 0;
  bool get isPositive => halalas > 0;

  /// True when there is no fractional halala part (e.g. 85.00).
  bool get isWhole => halalas % 100 == 0;

  Money operator +(Money other) => Money._(halalas + other.halalas);
  Money operator -(Money other) => Money._(halalas - other.halalas);
  bool operator <(Money other) => halalas < other.halalas;
  bool operator <=(Money other) => halalas <= other.halalas;
  bool operator >(Money other) => halalas > other.halalas;
  bool operator >=(Money other) => halalas >= other.halalas;

  /// Never negative.
  Money clampNonNegative() => isNegative ? const Money.zero() : this;

  /// `this / total` as a 0‥1 fraction (0 when [total] is zero).
  double fractionOf(Money total) {
    if (total.halalas <= 0) return 0;
    return (halalas / total.halalas).clamp(0.0, 1.0).toDouble();
  }

  @override
  int compareTo(Money other) => halalas.compareTo(other.halalas);

  @override
  bool operator ==(Object other) =>
      other is Money && other.halalas == halalas;

  @override
  int get hashCode => halalas.hashCode;

  @override
  String toString() => 'Money(${riyals.toStringAsFixed(2)} SAR)';
}
