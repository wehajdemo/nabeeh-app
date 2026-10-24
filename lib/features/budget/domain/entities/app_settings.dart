import 'package:flutter/foundation.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';

/// User preferences (alerts and appearance).
@immutable
class AppSettings {
  const AppSettings({
    this.dailyLimitAlerts = true,
    this.officialPayoutAlerts = true,
    this.appearance = AppearanceMode.system,
    this.enabledPayoutAlertIds = const {},
  });

  /// Morning reminder with today's spending limit.
  final bool dailyLimitAlerts;

  /// Master switch for official payout-date notifications.
  final bool officialPayoutAlerts;

  /// Light, dark, or follow the phone.
  final AppearanceMode appearance;

  /// Payout programs the user asked to be reminded about.
  final Set<String> enabledPayoutAlertIds;

  AppSettings copyWith({
    bool? dailyLimitAlerts,
    bool? officialPayoutAlerts,
    AppearanceMode? appearance,
    Set<String>? enabledPayoutAlertIds,
  }) {
    return AppSettings(
      dailyLimitAlerts: dailyLimitAlerts ?? this.dailyLimitAlerts,
      officialPayoutAlerts: officialPayoutAlerts ?? this.officialPayoutAlerts,
      appearance: appearance ?? this.appearance,
      enabledPayoutAlertIds:
          enabledPayoutAlertIds ?? this.enabledPayoutAlertIds,
    );
  }
}
