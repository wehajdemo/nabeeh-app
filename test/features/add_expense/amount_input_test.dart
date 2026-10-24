import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/add_expense/domain/amount_input.dart';

AmountInput type(String keys) {
  var input = const AmountInput.empty();
  for (final key in keys.split('')) {
    input = key == '.' ? input.pressDecimalPoint() : input.pressDigit(key);
  }
  return input;
}

void main() {
  test('starts at zero and replaces the leading zero', () {
    expect(const AmountInput.empty().text, '0');
    expect(type('7').text, '7');
    expect(type('00').text, '0');
    expect(type('05').text, '5');
  });

  test('allows one decimal point and two decimals', () {
    expect(type('0.').text, '0.');
    expect(type('1.5.').text, '1.5');
    expect(type('12.345').text, '12.34');
    expect(type('12.34').amount, Money.fromRiyals(12.34));
  });

  test('caps the integer part at six digits', () {
    expect(type('12345678').text, '123456');
  });

  test('backspace walks back to zero', () {
    var input = type('12.5');
    input = input.backspace();
    expect(input.text, '12.');
    input = input.backspace().backspace();
    expect(input.text, '1');
    input = input.backspace();
    expect(input.text, '0');
    expect(input.backspace().text, '0');
  });

  test('presets replace the current value', () {
    expect(type('3.5').preset(50).amount, Money.fromRiyals(50));
  });
}
