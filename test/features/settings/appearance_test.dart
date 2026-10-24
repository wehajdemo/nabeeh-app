import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/app.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';
import 'package:rateby/features/settings/application/appearance_providers.dart';
import 'package:rateby/features/shell/presentation/widgets/app_bottom_nav.dart';

import '../../support/test_overrides.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [fixedClock(), demoStore()],
      child: const RatebyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Brightness shownBrightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.descendant(
    of: find.byType(AppBottomNav),
    matching: find.text('الإعدادات'),
  ));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => AppColors.use(Brightness.light));

  group('resolveBrightness', () {
    test('fixed modes ignore the phone', () {
      expect(
        resolveBrightness(AppearanceMode.light, Brightness.dark),
        Brightness.light,
      );
      expect(
        resolveBrightness(AppearanceMode.dark, Brightness.light),
        Brightness.dark,
      );
    });

    test('system mode follows the phone', () {
      expect(
        resolveBrightness(AppearanceMode.system, Brightness.dark),
        Brightness.dark,
      );
      expect(
        resolveBrightness(AppearanceMode.system, Brightness.light),
        Brightness.light,
      );
    });

    test('unknown stored names fall back to system', () {
      expect(AppearanceMode.fromName(null), AppearanceMode.system);
      expect(AppearanceMode.fromName('sepia'), AppearanceMode.system);
      expect(AppearanceMode.fromName('dark'), AppearanceMode.dark);
    });
  });

  testWidgets('follows the phone by default, live', (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await pumpApp(tester);
    expect(shownBrightness(tester), Brightness.light);
    expect(AppColors.surface, AppPalette.light.surface);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(shownBrightness(tester), Brightness.dark);
    expect(AppColors.surface, AppPalette.dark.surface);
  });

  testWidgets('choosing dark in Settings switches the whole app',
      (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await pumpApp(tester);
    await openSettings(tester);

    final row = find.text('المظهر');
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text('حسب الهاتف'), findsWidgets);

    await tester.tap(find.text('داكن (ليلي)').last);
    await tester.pumpAndSettle();

    expect(shownBrightness(tester), Brightness.dark);
    expect(AppColors.surface, AppPalette.dark.surface);
    // Still on the Settings tab, and the row shows the choice.
    expect(find.text('الإعدادات المالية'), findsOneWidget);
    expect(find.text('داكن (ليلي)'), findsOneWidget);

    // The phone going light does not override an explicit choice.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(shownBrightness(tester), Brightness.dark);
  });

  testWidgets('choosing light wins over a dark phone', (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await pumpApp(tester);
    expect(shownBrightness(tester), Brightness.dark);

    await openSettings(tester);
    final row = find.text('المظهر');
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.text('فاتح').last);
    await tester.pumpAndSettle();

    expect(shownBrightness(tester), Brightness.light);
    expect(AppColors.surface, AppPalette.light.surface);
  });
}
