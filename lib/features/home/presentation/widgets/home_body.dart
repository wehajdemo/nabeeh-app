import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/ads/presentation/ad_native_slot.dart';
import 'package:rateby/features/home/application/home_state.dart';
import 'package:rateby/features/home/presentation/widgets/daily_allowance_card.dart';
import 'package:rateby/features/home/presentation/widgets/fixed_expenses_section.dart';
import 'package:rateby/features/home/presentation/widgets/greeting_header.dart';
import 'package:rateby/features/home/presentation/widgets/salary_countdown_card.dart';
import 'package:rateby/features/home/presentation/widgets/upgrade_banner.dart';

/// Scrollable composition of the Home sections. Pure layout: it receives a
/// ready [HomeState] and callbacks, and holds no logic of its own.
class HomeBody extends StatelessWidget {
  const HomeBody({
    required this.state,
    required this.onRefresh,
    required this.onLogExpense,
    required this.onUpgrade,
    super.key,
  });

  final HomeState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogExpense;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.margin,
          AppSpacing.xs,
          AppSpacing.margin,
          AppSpacing.lg,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                GreetingHeader(
                  today: state.today,
                  greeting: state.greeting,
                  userName: state.userName,
                  health: state.health,
                ),
                DailyAllowanceCard(
                  allowance: state.allowance,
                  health: state.health,
                ),
                SalaryCountdownCard(cycle: state.salaryCycle),
                PrimaryButton(
                  label: AppStrings.logExpense,
                  icon: Icons.add_circle_outline,
                  onPressed: onLogExpense,
                ),
                FixedExpensesSection(
                  expenses: state.fixedExpenses,
                  paidTotal: state.fixedExpensesPaidTotal,
                  total: state.fixedExpensesTotal,
                  today: state.today,
                ),
                const AdNativeSlot(),
                UpgradeBanner(onUpgrade: onUpgrade),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
