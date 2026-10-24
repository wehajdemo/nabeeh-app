import 'package:flutter/material.dart';

/// Type scale from the design system (IBM Plex Sans Arabic, bundled in
/// `assets/fonts`). Styles carry **no color** so they inherit from context;
/// apply one with `.copyWith(color: AppColors.x)`.
abstract final class AppTypography {
  static const String fontFamily = 'IBMPlexSansArabic';

  /// Emoji (the greeting wave) come from the system font; naming the common
  /// ones keeps them from rendering as empty boxes where the default
  /// fallback is missing.
  static const List<String> emojiFallback = [
    'Noto Color Emoji',
    'Segoe UI Emoji',
    'Apple Color Emoji',
  ];

  static TextStyle _style({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: emojiFallback,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  // ── Display ─────────────────────────────────────────────────────────────
  static final TextStyle displayHero = _style(
    size: 36,
    lineHeight: 48,
    weight: FontWeight.w700,
    letterSpacing: -0.72,
  );
  static final TextStyle displayHeroMobile = _style(
    size: 30,
    lineHeight: 40,
    weight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// The giant "available today" figure on the hero card.
  static final TextStyle displayAmount = _style(
    size: 68,
    lineHeight: 68,
    weight: FontWeight.w700,
    letterSpacing: -0.68,
  );

  // ── Headlines ───────────────────────────────────────────────────────────
  static final TextStyle headlineLg =
      _style(size: 26, lineHeight: 36, weight: FontWeight.w700);
  static final TextStyle headlineMd =
      _style(size: 20, lineHeight: 30, weight: FontWeight.w600);
  static final TextStyle headlineSm =
      _style(size: 18, lineHeight: 26, weight: FontWeight.w600);

  // ── Body ────────────────────────────────────────────────────────────────
  static final TextStyle bodyLg =
      _style(size: 16, lineHeight: 26, weight: FontWeight.w400);
  static final TextStyle bodyMd =
      _style(size: 14, lineHeight: 22, weight: FontWeight.w400);
  static final TextStyle bodySm =
      _style(size: 12, lineHeight: 18, weight: FontWeight.w400);

  // ── Labels ──────────────────────────────────────────────────────────────
  static final TextStyle labelLg =
      _style(size: 14, lineHeight: 20, weight: FontWeight.w600);
  static final TextStyle labelMd =
      _style(size: 12, lineHeight: 16, weight: FontWeight.w500);
  static final TextStyle labelSm =
      _style(size: 11, lineHeight: 14, weight: FontWeight.w500);
  static final TextStyle labelXs =
      _style(size: 10, lineHeight: 14, weight: FontWeight.w600);

  // ── Numeric ─────────────────────────────────────────────────────────────
  static final TextStyle currencyStat =
      _style(size: 32, lineHeight: 40, weight: FontWeight.w700);

  /// Material [TextTheme] so framework widgets (dialogs, snackbars…) match.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayHero,
        displayMedium: displayHeroMobile,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineSm,
        titleLarge: headlineMd,
        titleMedium: labelLg,
        titleSmall: labelMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelLarge: labelLg,
        labelMedium: labelMd,
        labelSmall: labelSm,
      );
}
