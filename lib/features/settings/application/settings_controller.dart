import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/navigation/navigation_controller.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';
import 'package:rateby/features/budget/domain/entities/budget_profile.dart';
import 'package:rateby/features/notifications/application/reminder_sync.dart';
import 'package:rateby/features/settings/application/settings_state.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';

/// Reads profile + preferences together and applies every Settings action.
class SettingsController extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final profile = await ref.watch(profileProvider.future);
    final preferences = await ref.watch(settingsProvider.future);
    return SettingsState(
      profile: profile ?? BudgetProfile.empty,
      preferences: preferences,
    );
  }

  Future<void> updateSalary(Money salary) =>
      ref.read(profileRepositoryProvider).updateNetSalary(salary);

  Future<void> updatePayDay(int day) =>
      ref.read(profileRepositoryProvider).updatePayDay(day);

  Future<void> addCommitment(CommitmentDraft draft) =>
      ref.read(profileRepositoryProvider).addCommitment(draft);

  Future<void> removeCommitment(String id) =>
      ref.read(profileRepositoryProvider).removeCommitment(id);

  /// Returns `false` only when the user turned alerts on but the device
  /// does not allow notifications (so the UI can explain how to fix it).
  ///
  /// Daily-limit alerts are a Plus feature: turning them on without a
  /// subscription throws [PlusRequiredException]. Turning them off is
  /// always allowed.
  Future<bool> setDailyLimitAlerts(bool value) async {
    if (value && !ref.read(isPlusProvider)) {
      throw const PlusRequiredException(PlusFeature.dailyLimitAlerts);
    }
    await _savePreferences((p) => p.copyWith(dailyLimitAlerts: value));
    return _permissionOk(value);
  }

  Future<bool> setOfficialPayoutAlerts(bool value) async {
    await _savePreferences((p) => p.copyWith(officialPayoutAlerts: value));
    return _permissionOk(value);
  }

  Future<void> setAppearance(AppearanceMode mode) =>
      _savePreferences((p) => p.copyWith(appearance: mode));

  Future<bool> _permissionOk(bool turnedOn) async =>
      !turnedOn || await ref.read(reminderSyncProvider).ensurePermission();

  /// Deletes every record. The app gate then shows onboarding again.
  Future<void> resetAll() async {
    await ref.read(profileRepositoryProvider).resetAll();
    ref.read(navigationControllerProvider.notifier).select(AppTab.home);
  }

  Future<void> _savePreferences(
    AppSettings Function(AppSettings current) update,
  ) async {
    final current = await ref.read(settingsProvider.future);
    await ref.read(settingsRepositoryProvider).saveSettings(update(current));
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
