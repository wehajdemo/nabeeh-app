import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/theme/app_colors.dart';

/// WCAG contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// A translucent [top] as it looks on [under].
Color _over(Color top, Color under) => Color.alphaBlend(top, under);

/// (text, background) pairs the screens actually draw, per palette.
Map<String, (Color, Color)> _pairs(AppPalette p) => {
      'body on surface': (p.onSurface, p.surface),
      'body on card': (p.onSurface, p.surfaceContainerLowest),
      'body on tile': (p.onSurface, p.surfaceContainer),
      'secondary text on surface': (p.onSurfaceVariant, p.surface),
      'secondary text on tile': (p.onSurfaceVariant, p.surfaceContainer),
      'secondary text on raised tile':
          (p.onSurfaceVariant, p.surfaceContainerHigh),
      'primary on surface': (p.primary, p.surface),
      'primary on card': (p.primary, p.surfaceContainerLowest),
      'secondary on card': (p.secondary, p.surfaceContainerLowest),
      'tertiary on surface': (p.tertiary, p.surface),
      'error on surface': (p.error, p.surface),
      'text on primary': (p.onPrimary, p.primary),
      'text on primary container': (p.onPrimary, p.primaryContainer),
      'container text on primary container':
          (p.onPrimaryContainer, p.primaryContainer),
      'text on secondary': (p.onSecondary, p.secondary),
      'text on error': (p.onError, p.error),
      'text on secondary container':
          (p.onSecondaryContainer, p.secondaryContainer),
      'text on tinted secondary chip': (
        p.onSecondaryContainer,
        _over(p.secondaryContainer40, p.surfaceContainerLowest)
      ),
      'text on fixed primary': (p.onPrimaryFixed, p.primaryFixed),
      'text on fixed tertiary': (p.onTertiaryFixed, p.tertiaryFixed),
      'warning chip': (
        p.tertiary,
        _over(p.tertiaryContainer15, p.surfaceContainerLowest)
      ),
      'snackbar text': (p.inverseOnSurface, p.inverseSurface),
    };

void main() {
  tearDown(() => AppColors.use(Brightness.light));

  for (final entry in {
    'light': AppPalette.light,
    'dark': AppPalette.dark,
  }.entries) {
    group('${entry.key} palette', () {
      test('every text pair is readable (WCAG AA, 4.5:1)', () {
        final failures = <String>[];
        _pairs(entry.value).forEach((name, pair) {
          final ratio = _contrast(pair.$1, pair.$2);
          if (ratio < 4.5) failures.add('$name: ${ratio.toStringAsFixed(2)}');
        });
        expect(failures, isEmpty);
      });
    });
  }

  test('state chips are readable in dark mode', () {
    const p = AppPalette.dark;
    for (final (fg, bg) in [
      (p.stateDanger, p.stateDangerBackground),
      (p.stateSafe, p.stateSafeBackground),
      (p.stateWarning, p.stateWarningBackground),
    ]) {
      expect(
        _contrast(fg, _over(bg, p.surfaceContainerLowest)),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('hero cards keep the light palette in both modes', () {
    AppColors.use(Brightness.dark);
    expect(AppColors.hero, same(AppPalette.light));
    // White text on the hero gradient must not depend on the mode.
    expect(AppColors.hero.onPrimary, const Color(0xFFFFFFFF));
    expect(AppColors.surface, AppPalette.dark.surface);
  });

  test('AppColors follows use() and switches back', () {
    AppColors.use(Brightness.dark);
    expect(AppColors.onSurface, AppPalette.dark.onSurface);
    AppColors.use(Brightness.light);
    expect(AppColors.onSurface, AppPalette.light.onSurface);
  });

  test('dark mode actually differs from light', () {
    expect(AppPalette.dark.surface, isNot(AppPalette.light.surface));
    expect(
      AppPalette.dark.surface.computeLuminance(),
      lessThan(AppPalette.dark.onSurface.computeLuminance()),
    );
  });
}
