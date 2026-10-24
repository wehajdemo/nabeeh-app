import 'package:flutter/material.dart';

/// Elevation tiers from DESIGN.md → "Elevation & Depth".
abstract final class AppShadows {
  /// Level 1 — card surface.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 2 — hero / interactive cards.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x140D5C3A),
      blurRadius: 25,
      spreadRadius: -5,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 10,
      spreadRadius: -6,
      offset: Offset(0, 8),
    ),
  ];

  /// Primary button glow (`shadow-lg shadow-primary/20`).
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: Color(0x33004328),
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 10),
    ),
  ];
}
