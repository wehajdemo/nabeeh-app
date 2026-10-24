/// Which look the app uses. [system] follows the phone's own setting.
enum AppearanceMode {
  system,
  light,
  dark;

  /// Parses the stored name; anything unknown means [system].
  static AppearanceMode fromName(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return system;
  }
}
