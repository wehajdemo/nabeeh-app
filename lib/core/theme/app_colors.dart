import 'package:flutter/material.dart';

/// Every color of one theme (light or dark).
@immutable
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.surfaceTint,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.onSurface,
    required this.onBackground,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.stateSafe,
    required this.stateSafeBackground,
    required this.stateWarning,
    required this.stateWarningBackground,
    required this.stateDanger,
    required this.stateDangerBackground,
    required this.onPrimary10,
    required this.onPrimary15,
    required this.onPrimary75,
    required this.onPrimary80,
    required this.primary40,
    required this.secondaryContainer10,
    required this.secondaryContainer30,
    required this.secondaryContainer40,
    required this.primaryFixed10,
    required this.tertiaryContainer15,
    required this.scrim,
  });

  final Color background;
  final Color surface;
  final Color surfaceDim;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color surfaceTint;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color onSurface;
  final Color onBackground;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color stateSafe;
  final Color stateSafeBackground;
  final Color stateWarning;
  final Color stateWarningBackground;
  final Color stateDanger;
  final Color stateDangerBackground;
  final Color onPrimary10;
  final Color onPrimary15;
  final Color onPrimary75;
  final Color onPrimary80;
  final Color primary40;
  final Color secondaryContainer10;
  final Color secondaryContainer30;
  final Color secondaryContainer40;
  final Color primaryFixed10;
  final Color tertiaryContainer15;
  final Color scrim;

  /// The Stitch design.
  static const AppPalette light = AppPalette(
    background: Color(0xFFFAF8FF),
    surface: Color(0xFFFAF8FF),
    surfaceDim: Color(0xFFD2D9F4),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F3FF),
    surfaceContainer: Color(0xFFEAEDFF),
    surfaceContainerHigh: Color(0xFFE2E7FF),
    surfaceContainerHighest: Color(0xFFDAE2FD),
    surfaceVariant: Color(0xFFDAE2FD),
    surfaceTint: Color(0xFF226B47),
    inverseSurface: Color(0xFF283044),
    inverseOnSurface: Color(0xFFEEF0FF),
    onSurface: Color(0xFF131B2E),
    onBackground: Color(0xFF131B2E),
    onSurfaceVariant: Color(0xFF404942),
    outline: Color(0xFF707971),
    outlineVariant: Color(0xFFBFC9C0),
    primary: Color(0xFF004328),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF0D5C3A),
    onPrimaryContainer: Color(0xFF8AD2A7),
    inversePrimary: Color(0xFF8ED6AA),
    primaryFixed: Color(0xFFA9F3C5),
    primaryFixedDim: Color(0xFF8ED6AA),
    onPrimaryFixed: Color(0xFF002111),
    onPrimaryFixedVariant: Color(0xFF005232),
    secondary: Color(0xFF006C49),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF6CF8BB),
    onSecondaryContainer: Color(0xFF00714D),
    secondaryFixed: Color(0xFF6FFBBE),
    secondaryFixedDim: Color(0xFF4EDEA3),
    tertiary: Color(0xFF5A2E00),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF7C4100),
    onTertiaryContainer: Color(0xFFFFB273),
    tertiaryFixed: Color(0xFFFFDCC3),
    tertiaryFixedDim: Color(0xFFFFB77D),
    onTertiaryFixed: Color(0xFF2F1500),
    onTertiaryFixedVariant: Color(0xFF6E3900),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    stateSafe: Color(0xFF059669),
    stateSafeBackground: Color(0xFFECFDF5),
    stateWarning: Color(0xFFD97706),
    stateWarningBackground: Color(0xFFFFFBEB),
    stateDanger: Color(0xFFDC2626),
    stateDangerBackground: Color(0xFFFEF2F2),
    onPrimary10: Color(0x1AFFFFFF),
    onPrimary15: Color(0x26FFFFFF),
    onPrimary75: Color(0xBFFFFFFF),
    onPrimary80: Color(0xCCFFFFFF),
    primary40: Color(0x66004328),
    secondaryContainer10: Color(0x1A6CF8BB),
    secondaryContainer30: Color(0x4D6CF8BB),
    secondaryContainer40: Color(0x666CF8BB),
    primaryFixed10: Color(0x1AA9F3C5),
    tertiaryContainer15: Color(0x267C4100),
    scrim: Color(0x66283044),
  );

  /// Dark scheme. Surfaces, text and the primary / secondary / tertiary /
  /// error / state families are re-toned; the "fixed" family and the hero
  /// gradients are identical in both modes (hero cards keep their emerald
  /// look — see [AppColors.hero]).
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0E1320),
    surface: Color(0xFF0E1320),
    surfaceDim: Color(0xFF0E1320),
    surfaceContainerLowest: Color(0xFF090D18),
    surfaceContainerLow: Color(0xFF151B2A),
    surfaceContainer: Color(0xFF191F2F),
    surfaceContainerHigh: Color(0xFF232A3A),
    surfaceContainerHighest: Color(0xFF2E3545),
    surfaceVariant: Color(0xFF2E3545),
    surfaceTint: Color(0xFF8ED6AA),
    inverseSurface: Color(0xFFDAE2FD),
    inverseOnSurface: Color(0xFF283044),
    onSurface: Color(0xFFDAE2FD),
    onBackground: Color(0xFFDAE2FD),
    onSurfaceVariant: Color(0xFFBFC9C0),
    outline: Color(0xFF89938B),
    outlineVariant: Color(0xFF404942),
    primary: Color(0xFF8ED6AA),
    onPrimary: Color(0xFF003920),
    // Solid brand fill in dark mode: mid-green so the dark `onPrimary`
    // text used on selected chips and toggles stays readable.
    primaryContainer: Color(0xFF8ED6AA),
    onPrimaryContainer: Color(0xFF003920),
    inversePrimary: Color(0xFF226B47),
    primaryFixed: Color(0xFFA9F3C5),
    primaryFixedDim: Color(0xFF8ED6AA),
    onPrimaryFixed: Color(0xFF002111),
    onPrimaryFixedVariant: Color(0xFF005232),
    secondary: Color(0xFF4EDEA3),
    onSecondary: Color(0xFF003824),
    secondaryContainer: Color(0xFF005236),
    onSecondaryContainer: Color(0xFF6CF8BB),
    secondaryFixed: Color(0xFF6FFBBE),
    secondaryFixedDim: Color(0xFF4EDEA3),
    tertiary: Color(0xFFFFB77D),
    onTertiary: Color(0xFF4E2600),
    tertiaryContainer: Color(0xFF6E3900),
    onTertiaryContainer: Color(0xFFFFDCC3),
    tertiaryFixed: Color(0xFFFFDCC3),
    tertiaryFixedDim: Color(0xFFFFB77D),
    onTertiaryFixed: Color(0xFF2F1500),
    onTertiaryFixedVariant: Color(0xFF6E3900),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    stateSafe: Color(0xFF34D399),
    stateSafeBackground: Color(0xFF0A2E24),
    stateWarning: Color(0xFFFBBF24),
    stateWarningBackground: Color(0xFF2E2308),
    stateDanger: Color(0xFFF87171),
    stateDangerBackground: Color(0xFF33191B),
    onPrimary10: Color(0x1A003920),
    onPrimary15: Color(0x26003920),
    onPrimary75: Color(0xBF003920),
    onPrimary80: Color(0xCC003920),
    primary40: Color(0x668ED6AA),
    secondaryContainer10: Color(0x1A005236),
    secondaryContainer30: Color(0x4D005236),
    secondaryContainer40: Color(0x66005236),
    primaryFixed10: Color(0x1AA9F3C5),
    tertiaryContainer15: Color(0x266E3900),
    scrim: Color(0x99000000),
  );
}

/// Single source of truth for every color in the app.
///
/// Values come from the Stitch design export (`DESIGN.md` + Tailwind config).
/// Widgets must never use raw `Color(0x…)` literals — add a token here instead.
///
/// The getters return the colors of the **current** palette, which the root
/// widget switches with [use] before building the app (the whole tree is
/// rebuilt when the mode changes). They are not compile-time constants, so
/// widgets that use them are not `const`.
abstract final class AppColors {
  static AppPalette _current = AppPalette.light;

  static AppPalette get current => _current;

  /// Makes [brightness] the palette every `AppColors.x` getter returns.
  static void use(Brightness brightness) {
    _current = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  }

  /// The light palette, regardless of mode. Used by hero cards (the dark
  /// emerald gradient cards), which look the same in both modes:
  /// `AppColors.hero.onPrimary` is always white.
  static const AppPalette hero = AppPalette.light;

  static Color get background => _current.background;
  static Color get surface => _current.surface;
  static Color get surfaceDim => _current.surfaceDim;
  static Color get surfaceContainerLowest => _current.surfaceContainerLowest;
  static Color get surfaceContainerLow => _current.surfaceContainerLow;
  static Color get surfaceContainer => _current.surfaceContainer;
  static Color get surfaceContainerHigh => _current.surfaceContainerHigh;
  static Color get surfaceContainerHighest => _current.surfaceContainerHighest;
  static Color get surfaceVariant => _current.surfaceVariant;
  static Color get surfaceTint => _current.surfaceTint;
  static Color get inverseSurface => _current.inverseSurface;
  static Color get inverseOnSurface => _current.inverseOnSurface;
  static Color get onSurface => _current.onSurface;
  static Color get onBackground => _current.onBackground;
  static Color get onSurfaceVariant => _current.onSurfaceVariant;
  static Color get outline => _current.outline;
  static Color get outlineVariant => _current.outlineVariant;
  static Color get primary => _current.primary;
  static Color get onPrimary => _current.onPrimary;
  static Color get primaryContainer => _current.primaryContainer;
  static Color get onPrimaryContainer => _current.onPrimaryContainer;
  static Color get inversePrimary => _current.inversePrimary;
  static Color get primaryFixed => _current.primaryFixed;
  static Color get primaryFixedDim => _current.primaryFixedDim;
  static Color get onPrimaryFixed => _current.onPrimaryFixed;
  static Color get onPrimaryFixedVariant => _current.onPrimaryFixedVariant;
  static Color get secondary => _current.secondary;
  static Color get onSecondary => _current.onSecondary;
  static Color get secondaryContainer => _current.secondaryContainer;
  static Color get onSecondaryContainer => _current.onSecondaryContainer;
  static Color get secondaryFixed => _current.secondaryFixed;
  static Color get secondaryFixedDim => _current.secondaryFixedDim;
  static Color get tertiary => _current.tertiary;
  static Color get onTertiary => _current.onTertiary;
  static Color get tertiaryContainer => _current.tertiaryContainer;
  static Color get onTertiaryContainer => _current.onTertiaryContainer;
  static Color get tertiaryFixed => _current.tertiaryFixed;
  static Color get tertiaryFixedDim => _current.tertiaryFixedDim;
  static Color get onTertiaryFixed => _current.onTertiaryFixed;
  static Color get onTertiaryFixedVariant => _current.onTertiaryFixedVariant;
  static Color get error => _current.error;
  static Color get onError => _current.onError;
  static Color get errorContainer => _current.errorContainer;
  static Color get onErrorContainer => _current.onErrorContainer;
  static Color get stateSafe => _current.stateSafe;
  static Color get stateSafeBackground => _current.stateSafeBackground;
  static Color get stateWarning => _current.stateWarning;
  static Color get stateWarningBackground => _current.stateWarningBackground;
  static Color get stateDanger => _current.stateDanger;
  static Color get stateDangerBackground => _current.stateDangerBackground;
  static Color get onPrimary10 => _current.onPrimary10;
  static Color get onPrimary15 => _current.onPrimary15;
  static Color get onPrimary75 => _current.onPrimary75;
  static Color get onPrimary80 => _current.onPrimary80;
  static Color get primary40 => _current.primary40;
  static Color get secondaryContainer10 => _current.secondaryContainer10;
  static Color get secondaryContainer30 => _current.secondaryContainer30;
  static Color get secondaryContainer40 => _current.secondaryContainer40;
  static Color get primaryFixed10 => _current.primaryFixed10;
  static Color get tertiaryContainer15 => _current.tertiaryContainer15;
  static Color get scrim => _current.scrim;

  // ── Gradients (identical in both modes) ─────────────────────────────────
  /// Hero card background (`from-primary via-primary-container to-surface-tint`).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF004328), Color(0xFF0D5C3A), Color(0xFF226B47)],
  );

  /// Progress fill on the hero card — "safe" state.
  static const LinearGradient progressSafe = LinearGradient(
    colors: [Color(0xFF6FFBBE), Color(0xFF6CF8BB)],
  );

  /// Progress fill on the hero card — "warning" state.
  static const LinearGradient progressWarning = LinearGradient(
    colors: [Color(0xFFFFB77D), Color(0xFFFFB273)],
  );

  /// Progress fill on the hero card — "danger" state.
  static const LinearGradient progressDanger = LinearGradient(
    colors: [Color(0xFFFFDAD6), Color(0xFFFFB4AB)],
  );
}
