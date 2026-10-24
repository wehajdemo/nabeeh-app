// Generates the store screenshots (App Store + Google Play) from the real app
// running on the demo data, framed on a branded background.
//   flutter test tool/store_shots_test.dart
// Output: store/ios/*.png (iPhone 6.9", 1320x2868), store/android/*.png
// (Galaxy-style, 1440x2880: Google Play allows at most a 2:1 aspect ratio),
// store/feature_graphic_1024x500.png.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/app.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/core/widgets/brand_mark.dart';
import 'package:rateby/features/add_expense/application/add_expense_controller.dart';
import 'package:rateby/features/add_expense/presentation/add_expense_screen.dart';
import 'package:rateby/features/shell/presentation/main_shell.dart';

import '../test/support/test_overrides.dart';

class _Spec {
  const _Spec(this.dir, this.canvas, this.logical, this.dpr, {required this.island});
  final String dir;
  final Size canvas; // final screenshot, px
  final Size logical; // app size, dp
  final double dpr;
  final bool island; // iPhone dynamic island vs. Android punch-hole
}

const _specs = [
  // iPhone 17 Pro Max class (6.9"): 1320 x 2868.
  _Spec('ios', Size(1320, 2868), Size(440, 956), 3, island: true),
  // Galaxy S25 Ultra class, cropped to Google Play's 2:1 limit.
  _Spec('android', Size(1440, 2880), Size(412, 823), 3.4951, island: false),
];

const _deep = Color(0xFF004328);
const _green = Color(0xFF0D5C3A);
const _mint = Color(0xFF6CF8BB);

enum _Screen { home, addExpense, goals, payments, upgrade, settings }

const _captions = {
  _Screen.home: ('اعرف كم تصرف اليوم', 'حدّك اليومي يتحدّث مع كل مصروف'),
  _Screen.addExpense: ('سجّل مصروفك في ثوانٍ', 'رقم سريع، وملاحظة اختيارية'),
  _Screen.goals: ('حقّق أهداف الادخار', 'تابع تقدمك نحو كل هدف'),
  _Screen.payments: ('لا تفوّت موعد الصرف', 'مواعيد الرواتب والدعم بتنبيه قبلها'),
  _Screen.upgrade: ('نبيه بلس', 'بدون إعلانات، وتصدير تقاريرك'),
  _Screen.settings: ('تحكّم كامل', 'تنبيهات ومظهر وتصدير'),
};

Future<void> _loadFonts() async {
  final loader = FontLoader('IBMPlexSansArabic');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/IBMPlexSansArabic-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('D:/Dev/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync())));
  await icons.load();
  // Emoji (the greeting waves): Segoe UI Emoji under the names Flutter falls back to.
  for (final name in ['Noto Color Emoji', 'Segoe UI Emoji', 'Apple Color Emoji']) {
    final emoji = FontLoader(name)
      ..addFont(Future.value(ByteData.sublistView(File('C:/Windows/Fonts/seguiemj.ttf').readAsBytesSync())));
    await emoji.load();
  }
}

TextPainter _text(String s, double size, Color color, FontWeight weight, double maxWidth) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: size, color: color, fontWeight: weight, height: 1.25),
    ),
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.center,
  )..layout(maxWidth: maxWidth);
}

Future<void> _writePng(String path, int w, int h, void Function(Canvas, Size) draw) async {
  final rec = ui.PictureRecorder();
  final size = Size(w.toDouble(), h.toDouble());
  draw(Canvas(rec), size);
  final image = await rec.endRecording().toImage(w, h);
  final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data.buffer.asUint8List());
}

void _frame(Canvas c, Size s, _Spec spec, ui.Image shot, String title, String subtitle) {
  c.drawRect(
    Offset.zero & s,
    Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, s.height), const [_green, _deep]),
  );
  // Soft glow top-left for depth.
  c.drawCircle(
    Offset(s.width * 0.1, s.height * 0.05),
    s.width * 0.6,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(s.width * 0.1, s.height * 0.05),
        s.width * 0.6,
        [const Color(0x3314804F), const Color(0x0014804F)],
      ),
  );

  final head = _text(title, s.width * 0.085, Colors.white, FontWeight.w700, s.width * 0.86);
  head.paint(c, Offset((s.width - head.width) / 2, s.height * 0.045));
  final sub = _text(subtitle, s.width * 0.042, _mint, FontWeight.w500, s.width * 0.86);
  sub.paint(c, Offset((s.width - sub.width) / 2, s.height * 0.045 + head.height + s.width * 0.012));

  // Phone: wide, hanging off the bottom edge.
  final phoneW = s.width * 0.82;
  final phoneH = phoneW * shot.height / shot.width;
  final bezel = s.width * 0.018;
  final left = (s.width - phoneW) / 2;
  final top = s.height * 0.205;
  final outer = RRect.fromRectAndRadius(
    Rect.fromLTWH(left - bezel, top - bezel, phoneW + bezel * 2, phoneH + bezel * 2),
    Radius.circular(phoneW * 0.115),
  );
  c.drawRRect(
    outer.shift(Offset(0, s.width * 0.012)),
    Paint()..color = const Color(0x55000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
  );
  c.drawRRect(outer, Paint()..color = const Color(0xFF0B0F0D));
  final screen = RRect.fromRectAndRadius(
    Rect.fromLTWH(left, top, phoneW, phoneH),
    Radius.circular(phoneW * 0.095),
  );
  c.save();
  c.clipRRect(screen);
  c.drawImageRect(
    shot,
    Rect.fromLTWH(0, 0, shot.width.toDouble(), shot.height.toDouble()),
    screen.outerRect,
    Paint()..filterQuality = FilterQuality.high,
  );
  c.restore();
  // Dynamic island / punch-hole camera.
  final cx = left + phoneW / 2;
  if (spec.island) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, top + phoneW * 0.045), width: phoneW * 0.27, height: phoneW * 0.075),
        Radius.circular(phoneW),
      ),
      Paint()..color = Colors.black,
    );
  } else {
    c.drawCircle(Offset(cx, top + phoneW * 0.04), phoneW * 0.017, Paint()..color = Colors.black);
  }
}

void main() {
  testWidgets('store screenshots', (tester) async {
    await _loadFonts();
    final key = GlobalKey();

    for (final spec in _specs) {
      tester.view
        ..physicalSize = Size(spec.logical.width * spec.dpr, spec.logical.height * spec.dpr)
        ..devicePixelRatio = spec.dpr
        ..padding = FakeViewPadding(top: 52 * spec.dpr, bottom: 20 * spec.dpr)
        ..viewPadding = FakeViewPadding(top: 52 * spec.dpr, bottom: 20 * spec.dpr);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [fixedClock(), demoStore()],
          child: RepaintBoundary(key: key, child: const RatebyApp()),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      final container = ProviderScope.containerOf(tester.element(find.byType(RatebyApp)));

      for (final screen in _Screen.values) {
        switch (screen) {
          case _Screen.home:
            container.read(navigationControllerProvider.notifier).select(AppTab.home);
          case _Screen.addExpense:
            final ctx = tester.element(find.byType(MainShell));
            unawaited(Navigator.of(ctx).push(AddExpenseScreen.route()));
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));
            await tester.pump(const Duration(seconds: 1));
            final form = container.read(addExpenseControllerProvider.notifier);
            for (final d in ['4', '5']) {
              form.pressDigit(d);
            }
            await tester.enterText(find.descendant(of: find.byType(AddExpenseScreen), matching: find.byType(TextField)), 'بقالة');
          case _Screen.goals:
            Navigator.of(tester.element(find.byType(AddExpenseScreen))).pop();
            container.read(navigationControllerProvider.notifier).select(AppTab.goals);
          case _Screen.payments:
            container.read(navigationControllerProvider.notifier).select(AppTab.payments);
          case _Screen.upgrade:
            container.read(navigationControllerProvider.notifier).select(AppTab.upgrade);
          case _Screen.settings:
            container.read(navigationControllerProvider.notifier).select(AppTab.settings);
        }
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 2));

        await tester.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final shot = await boundary.toImage(pixelRatio: spec.dpr);
          final (title, sub) = _captions[screen]!;
          final n = (screen.index + 1).toString().padLeft(2, '0');
          await _writePng(
            'store/${spec.dir}/$n-${screen.name}.png',
            spec.canvas.width.toInt(),
            spec.canvas.height.toInt(),
            (c, s) => _frame(c, s, spec, shot, title, sub),
          );
        });
      }
      await tester.pumpWidget(const SizedBox());
    }

    // Google Play feature graphic, 1024 x 500.
    await tester.runAsync(() async {
      await _writePng('store/feature_graphic_1024x500.png', 1024, 500, (c, s) {
        c.drawRect(
          Offset.zero & s,
          Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(s.width, s.height), const [_green, _deep]),
        );
        c.save();
        c.translate(s.width * 0.60, s.height * 0.08);
        BrandMarkPainter(
          arcColor: Colors.white,
          ringColor: const Color(0xFFD8B98C),
          dotColor: const Color(0xFFFFB27A),
          fill: 0.9,
        ).paint(c, Size(s.height * 0.84, s.height * 0.84));
        c.restore();
        final name = _text('نبيه', 150, Colors.white, FontWeight.w700, 500);
        name.paint(c, Offset(s.width * 0.57 - name.width, s.height * 0.16));
        final tag = _text('اعرف كم تصرف اليوم', 44, _mint, FontWeight.w500, 520);
        tag.paint(c, Offset(s.width * 0.57 - tag.width, s.height * 0.16 + name.height + 10));
      });
    });
  });
}

void unawaited(Future<void> f) {}
