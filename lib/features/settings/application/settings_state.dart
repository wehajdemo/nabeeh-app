import 'package:flutter/foundation.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';

@immutable
class SettingsState {
  const SettingsState({required this.profile, required this.preferences});

  final BudgetProfile profile;
  final AppSettings preferences;

  /// Up to three commitment names for the row subtitle.
  List<String> get commitmentTitles =>
      [for (final c in profile.commitments.take(3)) c.title];
}
