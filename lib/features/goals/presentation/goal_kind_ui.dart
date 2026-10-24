import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/features/budget/domain/entities/savings_goal.dart';

/// Icon and colour tone per goal kind.
extension GoalKindUi on GoalKind {
  IconData get icon => switch (this) {
        GoalKind.emergency => Icons.health_and_safety_outlined,
        GoalKind.travel => Icons.flight_takeoff,
        GoalKind.car => Icons.directions_car_outlined,
        GoalKind.custom => Icons.flag_outlined,
      };

  Color get iconBackground => switch (this) {
        GoalKind.emergency => AppColors.primaryFixed,
        GoalKind.travel => AppColors.secondaryContainer40,
        GoalKind.car => AppColors.tertiaryFixed,
        GoalKind.custom => AppColors.surfaceContainer,
      };

  Color get iconForeground => switch (this) {
        GoalKind.emergency => AppColors.onPrimaryFixed,
        GoalKind.travel => AppColors.onSecondaryContainer,
        GoalKind.car => AppColors.onTertiaryFixed,
        GoalKind.custom => AppColors.onSurfaceVariant,
      };

  Color get progressColor => switch (this) {
        GoalKind.emergency => AppColors.primary,
        GoalKind.travel => AppColors.secondary,
        GoalKind.car => AppColors.tertiary,
        GoalKind.custom => AppColors.primaryContainer,
      };
}
