import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/core/widgets/widgets.dart';

void main() {
  testWidgets('StatusChip renders its label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusChip(label: 'مكتمل', tone: StatusTone.success),
        ),
      ),
    );

    expect(find.text('مكتمل'), findsOneWidget);
  });
}
