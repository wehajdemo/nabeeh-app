import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';
import 'package:rateby/features/budget/presentation/budget_health_ui.dart';

/// "✔ ميزانية منضبطة" — reflects today's [BudgetHealth].
class BudgetHealthChip extends StatelessWidget {
  const BudgetHealthChip({required this.health, super.key});

  final BudgetHealth health;

  @override
  Widget build(BuildContext context) {
    return InfoPill(
      label: health.label,
      icon: health.icon,
      iconColor: health.accent,
      background: health.chipBackground,
      foreground: health.chipForeground,
      textStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
