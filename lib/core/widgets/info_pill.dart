import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Compact label with an optional leading icon, on a tinted background.
class InfoPill extends StatelessWidget {
  const InfoPill({
    required this.label,
    required this.background,
    required this.foreground,
    super.key,
    this.icon,
    this.leading,
    this.iconColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.borderRadius = AppRadius.pill,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  /// Custom leading widget (e.g. a `Dot`); ignored when [icon] is set.
  final Widget? leading;
  final Color? iconColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final style = (textStyle ?? AppTypography.labelSm).copyWith(
      color: foreground,
    );
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: borderRadius),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: iconColor ?? AppColors.secondary),
              const SizedBox(width: 6),
            ] else if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(label, style: style, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
