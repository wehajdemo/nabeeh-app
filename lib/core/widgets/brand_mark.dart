import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';

/// The Nabeeh mark: a green arc (a smile / a cycle that closes at payday)
/// with a glowing dot above it. Drawn in code so it stays sharp at any size.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 40,
    this.arcColor,
    this.ringColor,
    this.dotColor,
  });

  final double size;
  final Color? arcColor;
  final Color? ringColor;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: BrandMarkPainter(
        arcColor: arcColor ?? AppColors.primary,
        ringColor: ringColor ?? const Color(0xFFF0D1A8),
        dotColor: dotColor ?? const Color(0xFFD97706),
      ),
    );
  }
}

class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({
    required this.arcColor,
    required this.ringColor,
    required this.dotColor,
    this.fill = 0.82,
  });

  final Color arcColor;
  final Color ringColor;
  final Color dotColor;

  /// Share of the canvas width the mark occupies.
  final double fill;

  // Geometry measured from the logo sheet, in units of the mark's width.
  static const double _aspect = 167 / 195; // height / width

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * fill;
    final h = w * _aspect;
    final origin = Offset((size.width - w) / 2, (size.height - h) / 2);
    Offset p(double x, double y) => origin + Offset(x * w, y * h / _aspect);

    // Arc: circle centre (0.5, 0.354·) radius 0.433, left end to upper right.
    final centre = p(0.5, 0.354 * _aspect);
    final radius = 0.433 * w;
    final arc = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.144 * w
      ..strokeCap = StrokeCap.round;
    const start = 175.2 * math.pi / 180;
    const sweep = -201.2 * math.pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      start,
      sweep,
      false,
      arc,
    );

    final dotCentre = p(0.467, 0.29 * _aspect);
    canvas.drawCircle(
      dotCentre,
      0.25 * w,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.03 * w,
    );
    canvas.drawCircle(dotCentre, 0.123 * w, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(BrandMarkPainter old) =>
      old.arcColor != arcColor ||
      old.ringColor != ringColor ||
      old.dotColor != dotColor ||
      old.fill != fill;
}
