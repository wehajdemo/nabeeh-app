import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';

/// Segmented wizard progress: [current] of [total] segments are filled,
/// starting from the reading-start edge (right in RTL).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    required this.current,
    required this.total,
    super.key,
  });

  /// 1-based number of the active step.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '$current/$total',
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          for (var i = 1; i <= total; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= current
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
