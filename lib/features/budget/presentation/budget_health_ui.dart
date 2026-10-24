import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';

/// Presentation mapping for [BudgetHealth] — keeps colors/copy out of widgets
/// and out of the domain layer.
extension BudgetHealthUi on BudgetHealth {
  String get label => switch (this) {
        BudgetHealth.onTrack => AppStrings.healthOnTrack,
        BudgetHealth.nearLimit => AppStrings.healthNearLimit,
        BudgetHealth.exceeded => AppStrings.healthExceeded,
      };

  IconData get icon => switch (this) {
        BudgetHealth.onTrack => Icons.verified,
        BudgetHealth.nearLimit => Icons.warning_amber_rounded,
        BudgetHealth.exceeded => Icons.error_rounded,
      };

  Color get chipBackground => switch (this) {
        BudgetHealth.onTrack => AppColors.surfaceContainer,
        BudgetHealth.nearLimit => AppColors.stateWarningBackground,
        BudgetHealth.exceeded => AppColors.stateDangerBackground,
      };

  Color get accent => switch (this) {
        BudgetHealth.onTrack => AppColors.secondary,
        BudgetHealth.nearLimit => AppColors.stateWarning,
        BudgetHealth.exceeded => AppColors.stateDanger,
      };

  Color get chipForeground => switch (this) {
        BudgetHealth.onTrack => AppColors.onSurface,
        BudgetHealth.nearLimit => AppColors.stateWarning,
        BudgetHealth.exceeded => AppColors.stateDanger,
      };

  /// Fill used on the dark hero card.
  LinearGradient get heroProgressGradient => switch (this) {
        BudgetHealth.onTrack => AppColors.progressSafe,
        BudgetHealth.nearLimit => AppColors.progressWarning,
        BudgetHealth.exceeded => AppColors.progressDanger,
      };
}
