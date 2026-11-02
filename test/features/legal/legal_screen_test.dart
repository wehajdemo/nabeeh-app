import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/links/link_launcher.dart';
import 'package:rateby/core/theme/app_theme.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';
import 'package:rateby/features/legal/presentation/legal_screen.dart';

import '../../support/legal_source.dart';

Future<void> pump(
  WidgetTester tester,
  LegalKind kind, {
  RecordingLinkLauncher? launcher,
  String Function()? read,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        legalFromDisk(read),
        if (launcher != null) linkLauncherProvider.overrideWithValue(launcher),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: LegalScreen(kind: kind),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('privacy policy shows its title, sections and effective date',
      (tester) async {
    await pump(tester, LegalKind.privacy);

    expect(find.text('سياسة الخصوصية'), findsOneWidget); // app bar
    expect(find.text('من نحن'), findsOneWidget);
    expect(find.text('بياناتك المالية: على جهازك، ونسخة اختيارية في حسابك'), findsOneWidget);
    expect(find.textContaining('تاريخ السريان:'), findsWidgets);
  });

  testWidgets('terms show the subscription section', (tester) async {
    await pump(tester, LegalKind.terms);

    expect(find.text('شروط الاستخدام'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('نبيه بلس'), 300);
    expect(find.text('نبيه بلس'), findsOneWidget);
  });

  testWidgets('support has a contact button that opens the mail app',
      (tester) async {
    final launcher = RecordingLinkLauncher();
    await pump(tester, LegalKind.support, launcher: launcher);

    await tester.tap(find.text('تواصل معنا'));
    await tester.pumpAndSettle();

    expect(launcher.opened, hasLength(1));
    expect(launcher.opened.single.scheme, 'mailto');
    expect(launcher.opened.single.path, contains('@'));
  });

  testWidgets('with no mail app the address is shown instead', (tester) async {
    final launcher = RecordingLinkLauncher(opens: false);
    await pump(tester, LegalKind.support, launcher: launcher);

    await tester.tap(find.text('تواصل معنا'));
    await tester.pumpAndSettle();

    expect(find.textContaining('تعذّر فتح تطبيق البريد'), findsOneWidget);
  });

  testWidgets('privacy and terms have no contact button', (tester) async {
    await pump(tester, LegalKind.privacy);
    expect(find.text('تواصل معنا'), findsNothing);
  });

  testWidgets('a broken file shows an error with retry', (tester) async {
    await pump(tester, LegalKind.privacy, read: () => 'garbage');

    expect(find.text('تعذّر تحميل الصفحة'), findsOneWidget);
  });
}
