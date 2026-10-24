import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/ads/presentation/ad_native_slot.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';
import 'package:rateby/features/goals/application/goals_controller.dart';
import 'package:rateby/features/goals/application/goals_state.dart';
import 'package:rateby/features/goals/presentation/goals_strings.dart';
import 'package:rateby/features/goals/presentation/widgets/goal_balance_sheet.dart';
import 'package:rateby/features/goals/presentation/widgets/goal_card.dart';
import 'package:rateby/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:rateby/features/goals/presentation/widgets/goals_empty_state.dart';
import 'package:rateby/features/goals/presentation/widgets/goals_header.dart';
import 'package:rateby/features/goals/presentation/widgets/goals_smart_note.dart';
import 'package:rateby/features/goals/presentation/widgets/goals_summary_card.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';
import 'package:rateby/features/upgrade/presentation/plus_prompt.dart';

/// Savings goals tab. Maps controller state to widgets and wires callbacks.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(goalsControllerProvider.notifier);
    final count = ref.read(goalsControllerProvider).valueOrNull?.goals.length ?? 0;
    if (!controller.canAddGoal(count)) {
      promptUpgrade(context, ref, GoalsStrings.limitReached(PlusLimits.freeGoalCount));
      return;
    }
    final draft = await showGoalFormSheet(context);
    if (draft == null || !context.mounted) return;
    await _run(context, () => controller.addGoal(draft));
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final draft = await showGoalFormSheet(context, editing: goal);
    if (draft == null) return;
    await _run(
      context,
      () => ref.read(goalsControllerProvider.notifier).updateGoal(goal.id, draft),
    );
  }

  Future<void> _updateBalance(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final change = await showGoalBalanceSheet(context, goal: goal);
    if (change == null || !context.mounted) return;
    final controller = ref.read(goalsControllerProvider.notifier);
    await _run(
      context,
      () => change.isDeposit
          ? controller.deposit(goal.id, change.amount)
          : controller.withdraw(goal.id, change.amount),
    );
    if (context.mounted) AppToast.show(context, GoalsStrings.balanceUpdated);
  }

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on PlusRequiredException {
      messenger.showSnackBar(
        SnackBar(content: Text(GoalsStrings.limitReached(PlusLimits.freeGoalCount))),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text(GoalsStrings.saveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        tooltip: GoalsStrings.newGoal,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: goals.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorRetryView(
          onRetry: () => ref.invalidate(goalsControllerProvider),
        ),
        data: (state) => _GoalsBody(
          state: state,
          onRefresh: ref.read(goalsControllerProvider.notifier).refresh,
          onCreate: () => _create(context, ref),
          onEdit: (goal) => _edit(context, ref, goal),
          onUpdateBalance: (goal) => _updateBalance(context, ref, goal),
        ),
      ),
    );
  }
}

class _GoalsBody extends StatelessWidget {
  const _GoalsBody({
    required this.state,
    required this.onRefresh,
    required this.onCreate,
    required this.onEdit,
    required this.onUpdateBalance,
  });

  final GoalsState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreate;
  final ValueChanged<SavingsGoal> onEdit;
  final ValueChanged<SavingsGoal> onUpdateBalance;

  @override
  Widget build(BuildContext context) {
    return ScreenBody(
      onRefresh: onRefresh,
      // Keeps the last card clear of the floating button.
      bottomPadding: AppSpacing.xl * 2.5,
      children: [
        GoalsHeader(onNewGoal: onCreate),
        if (state.isEmpty)
          GoalsEmptyState(onCreate: onCreate)
        else ...[
          GoalsSummaryCard(state: state),
          const SectionHeader(
            title: GoalsStrings.activeSection,
            icon: Icons.flag_outlined,
            trailing: GoalsStrings.linkedToDaily,
          ),
          for (final goal in state.goals)
            GoalCard(
              key: ValueKey(goal.id),
              goal: goal,
              onEdit: () => onEdit(goal),
              onUpdateBalance: () => onUpdateBalance(goal),
            ),
          const AdNativeSlot(),
          GoalsSmartNote(state: state),
        ],
      ],
    );
  }
}
