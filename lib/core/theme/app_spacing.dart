import 'package:flutter/widgets.dart';

/// Spacing scale (`space-xs … space-xl`) plus layout gutters/margins.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Gap between KPI widgets in a grid (`gutter-sm`).
  static const double gutterSm = 12;
  static const double gutter = 16;

  /// Horizontal screen margin on phones.
  static const double margin = 16;
  static const double marginTablet = 24;
  static const double marginDesktop = 40;

  /// Max content width on tablets (DESIGN.md → Layout & Spacing).
  static const double maxContentWidth = 640;

  // ── Ready-made paddings ─────────────────────────────────────────────────
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: margin);
  static const EdgeInsets cardMd = EdgeInsets.all(md);
  static const EdgeInsets cardSm = EdgeInsets.all(sm);
  static const EdgeInsets cardLg = EdgeInsets.all(lg);

  // ── Vertical gaps ───────────────────────────────────────────────────────
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);

  // ── Horizontal gaps ─────────────────────────────────────────────────────
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
}

/// Corner radii. Note: in the exported Tailwind config `rounded-xl` = 12px,
/// which is what cards use in the screens.
abstract final class AppRadius {
  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static const BorderRadius tile = BorderRadius.all(Radius.circular(base));
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
}

/// Fixed component dimensions.
abstract final class AppSizes {
  static const double topBarHeight = 64;
  static const double bottomNavHeight = 64;
  static const double minTouchTarget = 44;
  static const double buttonHeight = 52;
  static const double keypadKeyHeight = 56;
  static const double quickChipHeight = 44;
  static const double progressHeightLg = 12;
  static const double progressHeightSm = 6;
  static const double ringIndicator = 44;
}
