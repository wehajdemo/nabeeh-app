import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';

abstract interface class GoalsRepository {
  Stream<List<SavingsGoal>> watchGoals();
  Future<void> addGoal(GoalDraft draft);
  Future<void> updateGoal(String id, GoalDraft draft);

  /// Adds [amount] to the goal's saved balance (ignored unless positive).
  Future<void> deposit(String id, Money amount);

  /// Takes [amount] out of the saved balance, never below zero.
  Future<void> withdraw(String id, Money amount);

  /// Adds the monthly contribution to every goal for each payday that has
  /// passed since the last time. Returns how many paydays were credited.
  Future<int> creditDuePaydays();
}
