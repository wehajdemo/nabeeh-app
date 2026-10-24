import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';

/// White "Level 1" surface used by every content block.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = AppSpacing.cardMd,
    this.color,
    this.borderRadius = AppRadius.card,
    this.shadows = AppShadows.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  /// Defaults to the lowest surface of the current theme.
  final Color? color;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
