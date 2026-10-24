import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_spacing.dart';

/// Rounded square with a centered icon (category icons, calendar tile…).
class IconBadge extends StatelessWidget {
  const IconBadge({
    required this.icon,
    required this.background,
    required this.foreground,
    super.key,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = AppRadius.tile,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: iconSize, color: foreground),
      ),
    );
  }
}
