import 'package:flutter/foundation.dart';
import 'package:rateby/core/money/money.dart';

/// Immutable model of the number being typed on the keypad.
///
/// Pure Dart — all input rules live here so they can be unit-tested without
/// any widget or provider:
///  * a single leading `0` is replaced by the first digit pressed,
///  * at most one decimal point,
///  * at most [maxDecimalDigits] digits after it,
///  * at most [maxIntegerDigits] digits before it.
@immutable
class AmountInput {
  const AmountInput._(this.text);

  const AmountInput.empty() : text = '0';

  static const int maxIntegerDigits = 6;
  static const int maxDecimalDigits = 2;

  /// Raw text as typed, e.g. `0`, `12`, `12.`, `12.5`.
  final String text;

  Money get amount => Money.parse(text);

  AmountInput pressDigit(String digit) {
    assert(digit.length == 1 && '0123456789'.contains(digit));
    if (text == '0') return AmountInput._(digit);

    final dot = text.indexOf('.');
    if (dot >= 0) {
      final decimals = text.length - dot - 1;
      return decimals >= maxDecimalDigits ? this : AmountInput._('$text$digit');
    }
    return text.length >= maxIntegerDigits ? this : AmountInput._('$text$digit');
  }

  AmountInput pressDecimalPoint() =>
      text.contains('.') ? this : AmountInput._('$text.');

  AmountInput backspace() => text.length <= 1
      ? const AmountInput.empty()
      : AmountInput._(text.substring(0, text.length - 1));

  /// Replaces the whole value with a preset (e.g. the "50" chip).
  AmountInput preset(int riyals) => AmountInput._(riyals.toString());

  @override
  bool operator ==(Object other) => other is AmountInput && other.text == text;

  @override
  int get hashCode => text.hashCode;
}
