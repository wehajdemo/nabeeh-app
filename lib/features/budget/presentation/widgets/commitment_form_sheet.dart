import 'package:flutter/material.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/amount_text_input_formatter.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';
import 'package:rateby/features/budget/presentation/fixed_expense_ui.dart';

/// Opens the "add commitment" sheet. Resolves to `null` when dismissed.
Future<CommitmentDraft?> showCommitmentFormSheet(BuildContext context) {
  return showAppBottomSheet<CommitmentDraft>(
    context: context,
    builder: (_) => const _CommitmentForm(),
  );
}

class _CommitmentForm extends StatefulWidget {
  const _CommitmentForm();

  @override
  State<_CommitmentForm> createState() => _CommitmentFormState();
}

class _CommitmentFormState extends State<_CommitmentForm> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  FixedExpenseCategory _category = FixedExpenseCategory.carFinance;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  String? get _nameError =>
      _submitted && _name.text.trim().isEmpty ? BudgetStrings.nameRequired : null;

  String? get _amountError => _submitted && !Money.parse(_amount.text).isPositive
      ? BudgetStrings.amountRequired
      : null;

  void _submit() {
    setState(() => _submitted = true);
    final amount = Money.parse(_amount.text);
    if (_name.text.trim().isEmpty || !amount.isPositive) return;
    Navigator.of(context).pop(
      CommitmentDraft(
        title: _name.text.trim(),
        amount: amount,
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        const SheetHeader(
          title: BudgetStrings.addCommitmentTitle,
          subtitle: BudgetStrings.addCommitmentSubtitle,
          icon: Icons.receipt_long_outlined,
        ),
        AppTextField(
          label: BudgetStrings.commitmentName,
          hint: BudgetStrings.commitmentNameHint,
          controller: _name,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: BudgetStrings.commitmentAmount,
          hint: '0',
          suffixText: AppStrings.currencySymbol,
          controller: _amount,
          errorText: _amountError,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AmountTextInputFormatter()],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        Text(
          BudgetStrings.commitmentType,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        ChoiceChipBar<FixedExpenseCategory>(
          options: {
            for (final c in FixedExpenseCategory.values) c: c.label,
          },
          selected: _category,
          onSelected: (c) => setState(() => _category = c),
        ),
        PrimaryButton(
          label: BudgetStrings.saveCommitment,
          icon: Icons.check_circle_outline,
          onPressed: _submit,
        ),
      ],
    );
  }
}
