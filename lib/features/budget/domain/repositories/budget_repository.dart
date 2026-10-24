import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/budget_snapshot.dart';
import 'package:rateby/features/budget/domain/entities/expense.dart';

/// Contract between the domain and any data source (in-memory, SQLite, REST…).
/// The UI and controllers depend only on this interface.
abstract interface class BudgetRepository {
  /// Emits the current snapshot immediately, then again after every change.
  Stream<BudgetSnapshot> watchSnapshot();

  /// Records an expense against today's allowance.
  Future<void> logExpense(Money amount, {String? note});

  /// Every stored expense, oldest first (the app keeps about two months).
  Future<List<Expense>> loadExpenses();
}
