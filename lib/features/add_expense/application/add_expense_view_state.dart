import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/add_expense/application/add_expense_controller.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';

/// Which message sits under the amount.
enum AmountHint { prompt, deduct, overLimit, invalid }

/// Everything `AddExpenseScreen` renders, derived from the keypad state and
/// the live daily allowance. Recomputed automatically when either changes.
@immutable
class AddExpenseViewState {
  const AddExpenseViewState({
    required this.amountText,
    required this.hint,
    required this.hintAmount,
    required this.remaining,
    required this.remainingFraction,
    required this.isSaving,
    required this.savedAmount,
    required this.saveFailed,
  });

  /// Quick-pick chips, in riyals.
  static const List<int> quickAmounts = [10, 20, 50, 100];

  final String amountText;
  final AmountHint hint;

  /// Amount to interpolate into [hint] (deduction, or overshoot).
  final Money? hintAmount;

  /// Limit left today (`null` until the budget has loaded).
  final Money? remaining;

  /// 0‥1 share of the daily limit that would remain after this expense.
  final double remainingFraction;

  final bool isSaving;

  /// Non-null while the "saved" banner should be visible.
  final Money? savedAmount;
  final bool saveFailed;
}

final addExpenseViewStateProvider =
    Provider.autoDispose<AddExpenseViewState>((ref) {
  final form = ref.watch(addExpenseControllerProvider);
  final allowance = ref.watch(dailyAllowanceProvider).valueOrNull;

  final amount = form.input.amount;
  final remaining = allowance?.remaining;

  final AmountHint hint;
  Money? hintAmount;
  if (form.showValidationError) {
    hint = AmountHint.invalid;
  } else if (!amount.isPositive) {
    hint = AmountHint.prompt;
  } else if (remaining != null && amount > remaining) {
    hint = AmountHint.overLimit;
    hintAmount = amount - remaining;
  } else {
    hint = AmountHint.deduct;
    hintAmount = amount;
  }

  final fraction = (allowance == null || remaining == null)
      ? 0.0
      : (remaining - amount).clampNonNegative().fractionOf(allowance.dailyLimit);

  return AddExpenseViewState(
    amountText: form.input.text,
    hint: hint,
    hintAmount: hintAmount,
    remaining: remaining,
    remainingFraction: fraction,
    isSaving: form.status == AddExpenseStatus.saving,
    savedAmount:
        form.status == AddExpenseStatus.saved ? form.lastSaved : null,
    saveFailed: form.status == AddExpenseStatus.failed,
  );
});
