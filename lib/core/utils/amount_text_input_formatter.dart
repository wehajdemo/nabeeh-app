import 'package:flutter/services.dart';

/// Accepts only a non-negative decimal: up to [maxIntegerDigits] digits and
/// [maxDecimalDigits] after the point. Rejects (keeps the old value) otherwise.
class AmountTextInputFormatter extends TextInputFormatter {
  AmountTextInputFormatter({
    this.maxIntegerDigits = 7,
    this.maxDecimalDigits = 2,
  }) : _pattern = RegExp('^\\d{0,$maxIntegerDigits}(\\.\\d{0,$maxDecimalDigits})?\$');

  final int maxIntegerDigits;
  final int maxDecimalDigits;
  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
