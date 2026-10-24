import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/application/goals_state.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';

/// Exposes savings goals with their totals and owns create / edit actions.
class GoalsController extends AsyncNotifier<GoalsState> {
  @override
  Future<GoalsState> build() async {
    final profile = await ref.watch(profileProvider.future);
    final goals = await ref.watch(goalsProvider.future);
    return GoalsState.fromGoals(
      goals,
      payDay: profile?.payDay ?? BudgetProfile.defaultPayDay,
    );
  }

  /// Free users may keep [PlusLimits.freeGoalCount] goals; Plus is
  /// unlimited. Throws [PlusRequiredException] past the limit.
  Future<void> addGoal(GoalDraft draft) async {
    if (!canAddGoal(await ref.read(goalsProvider.future).then((g) => g.length))) {
      throw const PlusRequiredException(PlusFeature.unlimitedGoals);
    }
    await ref.read(goalsRepositoryProvider).addGoal(draft);
  }

  /// Whether one more goal fits the current plan, given [currentCount].
  bool canAddGoal(int currentCount) =>
      ref.read(isPlusProvider) || currentCount < PlusLimits.freeGoalCount;

  Future<void> updateGoal(String id, GoalDraft draft) =>
      ref.read(goalsRepositoryProvider).updateGoal(id, draft);

  Future<void> deposit(String id, Money amount) =>
      ref.read(goalsRepositoryProvider).deposit(id, amount);

  Future<void> withdraw(String id, Money amount) =>
      ref.read(goalsRepositoryProvider).withdraw(id, amount);

  /// Credits the monthly contributions of any paydays that passed since the
  /// last check. Returns how many paydays were credited.
  Future<int> creditDuePaydays() =>
      ref.read(goalsRepositoryProvider).creditDuePaydays();

  Future<void> refresh() async {
    ref.invalidate(goalsProvider);
    await ref.read(goalsControllerProvider.future);
  }
}

final goalsControllerProvider =
    AsyncNotifierProvider<GoalsController, GoalsState>(GoalsController.new);
