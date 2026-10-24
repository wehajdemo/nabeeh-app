import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/app.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/shell/presentation/widgets/app_bottom_nav.dart';

import 'support/legal_source.dart';
import 'support/test_overrides.dart';

Future<void> pumpApp(WidgetTester tester, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const RatebyApp()),
  );
  await tester.pumpAndSettle();
}

Finder navItem(String label) => find.descendant(
      of: find.byType(AppBottomNav),
      matching: find.text(label),
    );

void main() {
  testWidgets('first launch shows onboarding, finishing it opens the app',
      (tester) async {
    await pumpApp(tester, [fixedClock(), emptyStore()]);

    // Step 1 — salary. Continue is disabled until a salary is entered.
    expect(find.text('كم راتبك الشهري الصافي؟'), findsOneWidget);
    expect(find.text('خطوة 1 من 3'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '12000');
    await tester.pump();
    await tester.tap(find.text('متابعة للخطوة التالية'));
    await tester.pumpAndSettle();

    // Step 2 — commitments (three examples, total 3,450).
    expect(find.text('ما هي التزاماتك ومصاريفك الثابتة؟'), findsOneWidget);
    expect(find.text('3,450'), findsOneWidget);
    await tester.tap(find.text('متابعة للخطوة الأخيرة'));
    await tester.pumpAndSettle();

    // Step 3 — payday and the live summary (8,550 ÷ 30 days = 285).
    expect(find.text('متى موعد نزول راتبك الشهري؟'), findsOneWidget);
    expect(find.text('285'), findsOneWidget);
    await tester.tap(find.text('بدء استخدام نبيه الآن ✨'));
    await tester.pumpAndSettle();

    // Home, computed from the entered numbers.
    expect(find.text('المصروف اليومي المتاح'), findsOneWidget);
    expect(find.text('كم راتبك الشهري الصافي؟'), findsNothing);
  });

  testWidgets('returning user lands on Home and can visit every tab',
      (tester) async {
    await pumpApp(tester, [fixedClock(), demoStore()]);

    expect(find.text('المصروف اليومي المتاح'), findsOneWidget);

    await tester.tap(navItem('الأهداف'));
    await tester.pumpAndSettle();
    expect(find.text('أهدافي الادخارية'), findsOneWidget);
    expect(find.text('صندوق الطوارئ'), findsOneWidget);

    await tester.tap(navItem('الصرف'));
    await tester.pumpAndSettle();
    expect(find.text('مواعيد الرواتب والدعم'), findsOneWidget);
    expect(find.text('رواتب القطاع الحكومي'), findsOneWidget);

    await tester.tap(navItem('الترقية'));
    await tester.pumpAndSettle();
    expect(find.text('نبيه بلس'), findsWidgets);
    expect(find.text('اشترك الآن واستمتع بـ 7 أيام مجاناً'), findsOneWidget);

    await tester.tap(navItem('الإعدادات'));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات المالية'), findsOneWidget);
    expect(find.text('الراتب الشهري الصافي'), findsOneWidget);
  });

  testWidgets('resetting the account in Settings returns to onboarding',
      (tester) async {
    await pumpApp(tester, [fixedClock(), demoStore()]);
    await tester.tap(navItem('الإعدادات'));
    await tester.pumpAndSettle();

    final reset = find.text('تصفير الحساب والبدء من جديد');
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.text('هل أنت متأكد؟'), findsOneWidget);

    await tester.tap(find.text('نعم، احذف كل شيء'));
    await tester.pumpAndSettle();
    expect(find.text('كم راتبك الشهري الصافي؟'), findsOneWidget);
  });

  testWidgets('Settings opens the privacy policy, terms and support pages',
      (tester) async {
    await pumpApp(tester, [fixedClock(), demoStore(), legalFromDisk()]);
    await tester.tap(navItem('الإعدادات'));
    await tester.pumpAndSettle();

    for (final entry in {
      'سياسة الخصوصية والأمان': 'سياسة الخصوصية',
      'شروط الاستخدام': 'شروط الاستخدام',
      'الدعم والمساعدة': 'الدعم والمساعدة',
    }.entries) {
      final tile = find.text(entry.key);
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets, reason: entry.key);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('الإعدادات المالية'), findsOneWidget);
    }
  });

  testWidgets('a free user hitting the goal limit is sent to the upgrade tab',
      (tester) async {
    await pumpApp(tester, [fixedClock(), demoStore()]);
    await tester.tap(navItem('الأهداف'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('هدف جديد'));
    await tester.pumpAndSettle();

    expect(find.textContaining('النسخة المجانية تتسع لـ 3 أهداف'), findsOneWidget);
    expect(find.text('اشترك الآن واستمتع بـ 7 أيام مجاناً'), findsOneWidget);
  });

  testWidgets('a subscriber can add more goals and sees an active-plan card',
      (tester) async {
    await pumpApp(tester, [fixedClock(), demoStore(), plusActive()]);
    await tester.tap(navItem('الأهداف'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('هدف جديد'));
    await tester.pumpAndSettle();
    expect(find.textContaining('النسخة المجانية تتسع'), findsNothing);

    // Close the form, then look at the Upgrade tab.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(navItem('الترقية'));
    await tester.pumpAndSettle();

    expect(find.text('اشتراكك في نبيه بلس نشط'), findsOneWidget);
    expect(find.text('اشترك الآن واستمتع بـ 7 أيام مجاناً'), findsNothing);
  });

  testWidgets('a free user turning on daily-limit alerts is sent to upgrade',
      (tester) async {
    await pumpApp(tester, [fixedClock(), demoStore()]);
    await tester.tap(navItem('الإعدادات'));
    await tester.pumpAndSettle();

    // The daily-limit switch is the first one in the preferences section.
    final daily = find.byType(AppSwitch).first;
    await tester.ensureVisible(daily);
    await tester.tap(daily);
    await tester.pumpAndSettle();

    expect(find.text('اشترك الآن واستمتع بـ 7 أيام مجاناً'), findsOneWidget);
  });
}
