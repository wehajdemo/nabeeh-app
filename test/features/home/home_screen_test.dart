import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/theme/app_theme.dart';
import 'package:rateby/features/home/presentation/home_screen.dart';

import '../../support/test_overrides.dart';

void main() {
  testWidgets('Home shows the allowance, countdown and fixed expenses',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [fixedClock(), demoStore()],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('198'), findsOneWidget); // 221 limit − 23 spent
    expect(find.text('باقي 5 أيام'), findsOneWidget);
    expect(find.text('قسط تمويل السيارة'), findsOneWidget);
    expect(find.text('ميزانية منضبطة'), findsOneWidget);
    expect(find.text('مساء الخير، ريان 👋'), findsOneWidget);
  });
}
