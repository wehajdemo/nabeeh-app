import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/amount_text_input_formatter.dart';
import 'package:rateby/core/utils/money_formatter.dart';

/// Large emerald amount field with a pencil icon and fixed `ر.س` suffix.
///
/// Keeps its own [TextEditingController] (ephemeral UI state) but stays in
/// sync when [value] changes from outside, e.g. a preset chip.
class SalaryInputField extends StatefulWidget {
  const SalaryInputField({
    required this.value,
    required this.onChanged,
    super.key,
    this.autofocus = false,
  });

  final Money value;
  final ValueChanged<Money> onChanged;
  final bool autofocus;

  @override
  State<SalaryInputField> createState() => _SalaryInputFieldState();
}

class _SalaryInputFieldState extends State<SalaryInputField> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.value),
  );

  static String _format(Money value) =>
      value.isZero ? '' : MoneyFormatter.format(value).replaceAll(',', '');

  @override
  void didUpdateWidget(SalaryInputField old) {
    super.didUpdateWidget(old);
    // Only overwrite the text when the change did not come from typing.
    if (Money.parse(_controller.text) != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: widget.autofocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [AmountTextInputFormatter()],
                onChanged: (text) => widget.onChanged(Money.parse(text)),
                cursorColor: AppColors.primary,
                style: AppTypography.currencyStat.copyWith(
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTypography.currencyStat.copyWith(
                    color: AppColors.outlineVariant,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixText: ' ${AppStrings.currencySymbol}',
                  suffixStyle: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadius.tile,
              ),
              child: SizedBox.square(
                dimension: 36,
                child: Icon(Icons.edit_outlined, size: 18, color: AppColors.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
