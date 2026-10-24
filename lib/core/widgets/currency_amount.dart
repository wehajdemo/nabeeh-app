import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/utils/money_formatter.dart';

/// `1,850 ر.س` — the figure and the riyal symbol with independent styles,
/// sharing one baseline (DESIGN.md: the symbol is "two steps smaller").
class CurrencyAmount extends StatelessWidget {
  const CurrencyAmount({
    required this.amount,
    required this.amountStyle,
    required this.symbolStyle,
    super.key,
    this.gap = 4,
    this.exactDecimals = false,
  });

  final Money amount;
  final TextStyle amountStyle;
  final TextStyle symbolStyle;
  final double gap;

  /// Force two decimals (`185.00`).
  final bool exactDecimals;

  @override
  Widget build(BuildContext context) {
    final text = exactDecimals
        ? MoneyFormatter.formatExact(amount)
        : MoneyFormatter.format(amount);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(text, style: amountStyle),
        SizedBox(width: gap),
        Text(AppStrings.currencySymbol, style: symbolStyle),
      ],
    );
  }
}
