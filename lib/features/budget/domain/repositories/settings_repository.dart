import 'package:rateby/features/budget/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  Stream<AppSettings> watchSettings();
  Future<void> saveSettings(AppSettings settings);
}
