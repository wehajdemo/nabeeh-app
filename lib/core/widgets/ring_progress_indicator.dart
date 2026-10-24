import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';

/// Circular progress ring with a centered [child] (e.g. "83%").
class RingProgressIndicator extends StatelessWidget {
  const RingProgressIndicator({
    required this.value,
    super.key,
    this.size = AppSizes.ringIndicator,
    this.strokeWidth = 3,
    this.trackColor,
    this.progressColor,
    this.child,
  });

  /// 0‥1.
  final double value;
  final double size;
  final double strokeWidth;
  /// Default to the theme's container surface / secondary color.
  final Color? trackColor;
  final Color? progressColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0).toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (context, animated, _) => CustomPaint(
          painter: _RingPainter(
            value: animated,
            strokeWidth: strokeWidth,
            trackColor: trackColor ?? AppColors.surfaceContainer,
            progressColor: progressColor ?? AppColors.secondary,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);

    if (value <= 0) return;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progressColor;
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
