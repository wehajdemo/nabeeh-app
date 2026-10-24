import 'package:flutter/material.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';
import 'package:rateby/features/budget/presentation/widgets/salary_input_field.dart';

/// Edit-salary sheet. Resolves to the new amount, or `null` if dismissed.
Future<Money?> showSalarySheet(BuildContext context, {required Money initial}) {
  return showAppBottomSheet<Money>(
    context: context,
    builder: (_) => _SalarySheet(initial: initial),
  );
}

class _SalarySheet extends StatefulWidget {
  const _SalarySheet({required this.initial});

  final Money initial;

  @override
  State<_SalarySheet> createState() => _SalarySheetState();
}

class _SalarySheetState extends State<_SalarySheet> {
  late Money _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        const SheetHeader(
          title: BudgetStrings.editSalaryTitle,
          subtitle: BudgetStrings.editSalarySubtitle,
          icon: Icons.payments_outlined,
        ),
        SalaryInputField(
          value: _value,
          autofocus: true,
          onChanged: (v) => setState(() => _value = v),
        ),
        PrimaryButton(
          label: BudgetStrings.save,
          icon: Icons.check_circle_outline,
          onPressed: _value.isPositive
              ? () => Navigator.of(context).pop(_value)
              : null,
        ),
      ],
    );
  }
}
