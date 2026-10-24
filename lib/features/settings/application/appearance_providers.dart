import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';

/// The saved choice. Until preferences load (a few milliseconds) the app
/// follows the phone, which is also the default.
final appearanceModeProvider = Provider<AppearanceMode>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.appearance ??
      AppearanceMode.system;
});

/// Turns a saved [mode] into the brightness to draw with.
Brightness resolveBrightness(AppearanceMode mode, Brightness platform) {
  return switch (mode) {
    AppearanceMode.light => Brightness.light,
    AppearanceMode.dark => Brightness.dark,
    AppearanceMode.system => platform,
  };
}
