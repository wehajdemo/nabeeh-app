import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/amount_text_input_formatter.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/application/goal_balance_change.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';

/// Sheet for adding money to (or taking money out of) a goal's saved balance.
/// Resolves to `null` when dismissed.
Future<GoalBalanceChange?> showGoalBalanceSheet(
  BuildContext context, {
  required SavingsGoal goal,
}) {
  return showAppBottomSheet<GoalBalanceChange>(
    context: context,
    builder: (_) => _GoalBalanceForm(goal: goal),
  );
}

class _GoalBalanceForm extends StatefulWidget {
  const _GoalBalanceForm({required this.goal});

  final SavingsGoal goal;

  @override
  State<_GoalBalanceForm> createState() => _GoalBalanceFormState();
}

class _GoalBalanceFormState extends State<_GoalBalanceForm> {
  final TextEditingController _amount = TextEditingController();
  bool _isDeposit = true;
  bool _submitted = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Money get _value => Money.parse(_amount.text);

  String? get _error {
    if (!_submitted) return null;
    if (!_value.isPositive) return GoalsStrings.amountRequired;
    if (!_isDeposit && _value > widget.goal.saved) {
      return GoalsStrings.withdrawTooHigh;
    }
    return null;
  }

  void _submit() {
    setState(() => _submitted = true);
    if (_error != null) return;
    Navigator.of(context).pop(
      GoalBalanceChange(isDeposit: _isDeposit, amount: _value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        SheetHeader(
          title: GoalsStrings.balanceTitle,
          subtitle: goal.title,
          icon: Icons.savings_outlined,
        ),
        ChoiceChipBar<bool>(
          options: const {
            true: GoalsStrings.addMoney,
            false: GoalsStrings.withdrawMoney,
          },
          selected: _isDeposit,
          onSelected: (value) => setState(() => _isDeposit = value),
        ),
        AppTextField(
          label: GoalsStrings.amountLabel,
          hint: '0',
          suffixText: AppStrings.currencySymbol,
          controller: _amount,
          errorText: _error,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AmountTextInputFormatter()],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        Text(
          GoalsStrings.currentBalance(MoneyFormatter.format(goal.saved)),
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        PrimaryButton(
          label: _isDeposit ? GoalsStrings.confirmDeposit : GoalsStrings.confirmWithdraw,
          icon: _isDeposit ? Icons.add : Icons.remove,
          onPressed: _submit,
        ),
        SecondaryButton(
          label: GoalsStrings.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
