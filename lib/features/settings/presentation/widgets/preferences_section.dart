import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/app_settings.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';
import 'package:rateby/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:rateby/features/settings/presentation/widgets/settings_section.dart';

/// Notification switches and appearance.
class PreferencesSection extends StatelessWidget {
  const PreferencesSection({
    required this.preferences,
    required this.onDailyAlertsChanged,
    required this.onPayoutAlertsChanged,
    required this.onAppearanceTap,
    required this.isPlus,
    this.onAdChoices,
    super.key,
  });

  final AppSettings preferences;
  final ValueChanged<bool> onDailyAlertsChanged;
  final ValueChanged<bool> onPayoutAlertsChanged;

  /// Opens the light / dark / system picker.
  final VoidCallback onAppearanceTap;

  /// Daily-limit alerts are a Plus feature.
  final bool isPlus;

  /// Opens the ad-consent form; `null` hides the row (not required).
  final VoidCallback? onAdChoices;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      icon: Icons.notifications_active_outlined,
      title: SettingsStrings.preferencesSection,
      children: [
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.alarm,
              title: SettingsStrings.dailyAlertTitle,
              subtitle: isPlus
                  ? SettingsStrings.dailyAlertSubtitle
                  : SettingsStrings.dailyAlertSubtitleLocked,
              trailing: AppSwitch(
                value: preferences.dailyLimitAlerts && isPlus,
                onChanged: onDailyAlertsChanged,
              ),
            ),
            SettingsTile(
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.secondary,
              title: SettingsStrings.payoutAlertTitle,
              subtitle: SettingsStrings.payoutAlertSubtitle,
              trailing: AppSwitch(
                value: preferences.officialPayoutAlerts,
                onChanged: onPayoutAlertsChanged,
              ),
            ),
            if (onAdChoices != null)
              SettingsTile(
                icon: Icons.tune,
                iconColor: AppColors.onSurfaceVariant,
                title: SettingsStrings.adChoicesTitle,
                subtitle: SettingsStrings.adChoicesSubtitle,
                onTap: onAdChoices,
              ),
            SettingsTile(
              icon: appearanceIcon(preferences.appearance),
              iconColor: AppColors.onSurfaceVariant,
              title: SettingsStrings.appearanceTitle,
              subtitle: SettingsStrings.appearanceSubtitle,
              onTap: onAppearanceTap,
              trailing: InfoPill(
                label: appearanceLabel(preferences.appearance),
                background: AppColors.surfaceContainer,
                foreground: AppColors.onSurfaceVariant,
                textStyle: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
