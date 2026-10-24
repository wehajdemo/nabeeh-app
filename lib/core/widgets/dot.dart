import 'package:flutter/material.dart';

/// Small filled circle (status dots, "live" indicators).
class Dot extends StatelessWidget {
  const Dot({required this.color, super.key, this.size = 6});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox(width: size, height: size),
    );
  }
}
