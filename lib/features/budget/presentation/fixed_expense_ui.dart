import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/core/utils/date_math.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/fixed_expense.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';

/// Presentation mapping for [FixedExpenseCategory].
extension FixedExpenseCategoryUi on FixedExpenseCategory {
  IconData get icon => switch (this) {
        FixedExpenseCategory.carFinance => Icons.directions_car_outlined,
        FixedExpenseCategory.buyNowPayLater => Icons.shopping_bag_outlined,
        FixedExpenseCategory.utilities => Icons.bolt_outlined,
      };

  Color get iconBackground => switch (this) {
        FixedExpenseCategory.carFinance => AppColors.surfaceContainer,
        FixedExpenseCategory.buyNowPayLater => AppColors.tertiaryFixed,
        FixedExpenseCategory.utilities => AppColors.surfaceContainerHigh,
      };

  Color get iconForeground => switch (this) {
        FixedExpenseCategory.carFinance => AppColors.primary,
        FixedExpenseCategory.buyNowPayLater => AppColors.onTertiaryFixed,
        FixedExpenseCategory.utilities => AppColors.onSurface,
      };

  /// Name shown on the category picker.
  String get label => switch (this) {
        FixedExpenseCategory.carFinance => BudgetStrings.categoryLoan,
        FixedExpenseCategory.buyNowPayLater => BudgetStrings.categoryBnpl,
        FixedExpenseCategory.utilities => BudgetStrings.categoryBills,
      };

  /// One-line explanation under a commitment's title.
  String get description => switch (this) {
        FixedExpenseCategory.carFinance => BudgetStrings.categoryLoanNote,
        FixedExpenseCategory.buyNowPayLater => BudgetStrings.categoryBnplNote,
        FixedExpenseCategory.utilities => BudgetStrings.categoryBillsNote,
      };
}

/// Presentation mapping for [FixedExpense]: icon, colors, chip and copy.
extension FixedExpenseUi on FixedExpense {
  IconData get icon => category.icon;
  Color get iconBackground => category.iconBackground;
  Color get iconForeground => category.iconForeground;

  StatusTone get statusTone => switch (status) {
        FixedExpenseStatus.completed => StatusTone.success,
        FixedExpenseStatus.dueSoon => StatusTone.warning,
        FixedExpenseStatus.scheduled => StatusTone.neutral,
      };

  String get statusLabel => switch (status) {
        FixedExpenseStatus.completed => AppStrings.statusCompleted,
        FixedExpenseStatus.dueSoon => AppStrings.statusDueSoon,
        FixedExpenseStatus.scheduled => AppStrings.statusScheduled,
      };

  /// Secondary line under the title, relative to [today].
  String subtitle(DateTime today) {
    switch (status) {
      case FixedExpenseStatus.completed:
        return isAutoPay
            ? AppStrings.autoPayScheduled
            : AppStrings.deductedOn(date.day, ArabicText.month(date));
      case FixedExpenseStatus.dueSoon:
        final days = DateMath.daysBetween(today, date);
        return AppStrings.dueIn(ArabicText.afterDays(days));
      case FixedExpenseStatus.scheduled:
        return AppStrings.scheduledOn(date.day, ArabicText.month(date));
    }
  }
}
