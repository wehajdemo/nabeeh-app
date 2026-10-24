import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Assembles the Material [ThemeData] from the centralized tokens.
abstract final class AppTheme {
  static ThemeData get light => forBrightness(Brightness.light);
  static ThemeData get dark => forBrightness(Brightness.dark);

  static ThemeData forBrightness(Brightness brightness) => _build(
        brightness == Brightness.dark ? AppPalette.dark : AppPalette.light,
        brightness,
      );

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      secondaryContainer: p.secondaryContainer,
      onSecondaryContainer: p.onSecondaryContainer,
      tertiary: p.tertiary,
      onTertiary: p.onTertiary,
      tertiaryContainer: p.tertiaryContainer,
      onTertiaryContainer: p.onTertiaryContainer,
      error: p.error,
      onError: p.onError,
      errorContainer: p.errorContainer,
      onErrorContainer: p.onErrorContainer,
      surface: p.surface,
      onSurface: p.onSurface,
      onSurfaceVariant: p.onSurfaceVariant,
      outline: p.outline,
      outlineVariant: p.outlineVariant,
      inverseSurface: p.inverseSurface,
      onInverseSurface: p.inverseOnSurface,
      inversePrimary: p.inversePrimary,
      surfaceTint: p.surfaceTint,
      surfaceContainerLowest: p.surfaceContainerLowest,
      surfaceContainerLow: p.surfaceContainerLow,
      surfaceContainer: p.surfaceContainer,
      surfaceContainerHigh: p.surfaceContainerHigh,
      surfaceContainerHighest: p.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.surface,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: p.onSurface,
        displayColor: p.onSurface,
      ),
      splashFactory: InkRipple.splashFactory,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.inverseSurface,
        contentTextStyle:
            AppTypography.labelLg.copyWith(color: p.inverseOnSurface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
