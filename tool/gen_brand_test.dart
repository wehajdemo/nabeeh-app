// Regenerates assets/brand/*.png from the code-drawn mark.
//   flutter test tool/gen_brand_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:rateby/core/widgets/brand_mark.dart';

const _green = Color(0xFF0D5C3A);
const _deep = Color(0xFF004328);

Future<void> _save(String name, int w, int h, void Function(Canvas, Size) draw) async {
  final recorder = ui.PictureRecorder();
  final size = Size(w.toDouble(), h.toDouble());
  draw(Canvas(recorder), size);
  final image = await recorder.endRecording().toImage(w, h);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  File('assets/brand/$name').writeAsBytesSync(bytes.buffer.asUint8List());
}

void _mark(Canvas c, Size s, {required Color arc, required Color ring, required Color dot, double fill = 0.82}) {
  BrandMarkPainter(arcColor: arc, ringColor: ring, dotColor: dot, fill: fill).paint(c, s);
}

void main() {
  testWidgets('generate brand assets', (tester) async {
    await tester.runAsync(() async {
      final bold = FontLoader('Plex')
        ..addFont(Future.value(ByteData.sublistView(
            File('assets/fonts/IBMPlexSansArabic-Bold.ttf').readAsBytesSync())));
      await bold.load();

      // Green mark on transparent.
      await _save('logo_mark.png', 1024, 1024, (c, s) => _mark(c, s,
          arc: _green, ring: const Color(0xFFF0D1A8), dot: const Color(0xFFD97706)));

      // Full-bleed launcher icon (green square, white arc).
      Paint bg(Size s) => Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(s.width, s.height),
            const [Color(0xFF0D5C3A), Color(0xFF14804F)]);
      await _save('app_icon.png', 1024, 1024, (c, s) {
        c.drawRect(Offset.zero & s, bg(s));
        _mark(c, s, arc: Colors.white, ring: const Color(0xFFD8B98C), dot: const Color(0xFFFFB27A), fill: 0.62);
      });
      // Adaptive foreground: transparent, inside the 66% safe zone.
      await _save('icon_foreground.png', 1024, 1024, (c, s) => _mark(c, s,
          arc: Colors.white, ring: const Color(0xFFD8B98C), dot: const Color(0xFFFFB27A), fill: 0.5));
      await _save('play_store_icon.png', 512, 512, (c, s) {
        c.drawRect(Offset.zero & s, bg(s));
        _mark(c, s, arc: Colors.white, ring: const Color(0xFFD8B98C), dot: const Color(0xFFFFB27A), fill: 0.62);
      });

      // Full logo: mark + راتبي + RATEBY on white.
      await _save('logo_full.png', 2400, 1200, (c, s) {
        c.drawRect(Offset.zero & s, Paint()..color = Colors.white);
        c.save();
        c.translate(s.width * 0.52, s.height * 0.1);
        _mark(c, const Size(800, 800), arc: _green, ring: const Color(0xFFF0D1A8), dot: const Color(0xFFD97706), fill: 0.95);
        c.restore();
        final word = TextPainter(
          text: const TextSpan(text: 'نبيه', style: TextStyle(fontFamily: 'Plex', fontSize: 420, color: _deep, fontWeight: FontWeight.w700)),
          textDirection: TextDirection.rtl,
        )..layout();
        word.paint(c, Offset(s.width * 0.48 - word.width, s.height * 0.22));
        final en = TextPainter(
          text: const TextSpan(text: 'N A B E E H', style: TextStyle(fontFamily: 'Plex', fontSize: 90, color: Color(0xFF444444), fontWeight: FontWeight.w700)),
          textDirection: TextDirection.ltr,
        )..layout();
        en.paint(c, Offset(s.width * 0.48 - word.width / 2 - en.width / 2, s.height * 0.22 + word.height + 20));
      });

      // ── Platform icons, written straight into the Android / web folders ──
      Future<void> out(String path, int px, void Function(Canvas, Size) draw) async {
        final rec = ui.PictureRecorder();
        draw(Canvas(rec), Size(px.toDouble(), px.toDouble()));
        final img = await rec.endRecording().toImage(px, px);
        final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
        File(path).writeAsBytesSync(data.buffer.asUint8List());
      }

      void icon(Canvas c, Size s, {double fill = 0.62, bool round = false}) {
        if (round) {
          c.clipRRect(RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(s.width * 0.22)));
        }
        c.drawRect(Offset.zero & s, bg(s));
        _mark(c, s, arc: Colors.white, ring: const Color(0xFFD8B98C), dot: const Color(0xFFFFB27A), fill: fill);
      }

      const res = 'android/app/src/main/res';
      const legacy = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
      for (final e in legacy.entries) {
        await out('$res/mipmap-${e.key}/ic_launcher.png', e.value, (c, s) => icon(c, s, round: true));
      }
      const fg = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432};
      for (final e in fg.entries) {
        final dir = Directory('$res/drawable-${e.key}')..createSync();
        await out('${dir.path}/ic_launcher_foreground.png', e.value, (c, s) => _mark(c, s,
            arc: Colors.white, ring: const Color(0xFFD8B98C), dot: const Color(0xFFFFB27A), fill: 0.5));
      }
      await out('web/icons/Icon-192.png', 192, (c, s) => icon(c, s, round: true));
      await out('web/icons/Icon-512.png', 512, (c, s) => icon(c, s, round: true));
      await out('web/icons/Icon-maskable-192.png', 192, (c, s) => icon(c, s, fill: 0.5));
      await out('web/icons/Icon-maskable-512.png', 512, (c, s) => icon(c, s, fill: 0.5));
      await out('web/favicon.png', 64, (c, s) => icon(c, s, round: true));

      // App Store icon: 1024 square, opaque, and NO alpha channel (Apple
      // rejects icons that have one) - so re-encode as 3-channel PNG.
      final rec = ui.PictureRecorder();
      icon(Canvas(rec), const Size(1024, 1024));
      final raw = await rec.endRecording().toImage(1024, 1024);
      final rawBytes = (await raw.toByteData(format: ui.ImageByteFormat.png))!;
      final decoded = img.decodePng(rawBytes.buffer.asUint8List())!;
      final opaque = decoded.convert(numChannels: 3);
      File('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png')
          .writeAsBytesSync(img.encodePng(opaque));
    });
  });
}
