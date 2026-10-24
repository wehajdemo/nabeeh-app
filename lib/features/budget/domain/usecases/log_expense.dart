import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/repositories/budget_repository.dart';

/// Thrown when an expense amount is zero or negative.
class InvalidExpenseAmountException implements Exception {
  const InvalidExpenseAmountException();

  @override
  String toString() => 'InvalidExpenseAmountException: amount must be > 0';
}

/// Business rule: only positive amounts may be logged.
class LogExpense {
  const LogExpense(this._repository);

  final BudgetRepository _repository;

  Future<void> call(Money amount, {String? note}) {
    if (!amount.isPositive) {
      return Future.error(const InvalidExpenseAmountException());
    }
    return _repository.logExpense(amount, note: _clean(note));
  }
}

/// Trims the note; blank means "no note".
String? _clean(String? note) {
  final trimmed = note?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
