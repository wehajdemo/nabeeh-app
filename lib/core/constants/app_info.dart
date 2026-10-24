/// Static facts about the app build. Keep in sync with `pubspec.yaml`.
abstract final class AppInfo {
  static const String version = '1.0.0';

  /// Whether this build shows ads. Must equal `features.ads` in
  /// `assets/legal/legal.json` (a test checks it) so the privacy policy
  /// describes what the app really does.
  static const bool hasAds = true;
}
