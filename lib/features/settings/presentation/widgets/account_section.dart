import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_info.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';
import 'package:rateby/features/settings/presentation/widgets/plus_promo_card.dart';
import 'package:rateby/features/settings/presentation/widgets/settings_section.dart';

/// Upgrade promo, export, privacy and about.
class AccountSection extends StatelessWidget {
  const AccountSection({
    required this.plusMonthlyPrice,
    required this.isPlus,
    required this.onUpgrade,
    required this.onExport,
    required this.onPrivacy,
    required this.onTerms,
    required this.onSupport,
    super.key,
  });

  final String plusMonthlyPrice;

  /// Subscribers do not see the upgrade promo.
  final bool isPlus;
  final VoidCallback onUpgrade;
  final VoidCallback onExport;
  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      icon: Icons.verified_user_outlined,
      title: SettingsStrings.accountSection,
      children: [
        if (!isPlus)
          PlusPromoCard(monthlyPrice: plusMonthlyPrice, onUpgrade: onUpgrade),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.ios_share,
              title: SettingsStrings.exportTitle,
              subtitle: SettingsStrings.exportSubtitle,
              trailing: const _Chevron(),
              onTap: onExport,
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              iconColor: AppColors.onSurfaceVariant,
              title: SettingsStrings.privacyTitle,
              subtitle: SettingsStrings.privacySubtitle,
              trailing: const _Chevron(),
              onTap: onPrivacy,
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.onSurfaceVariant,
              title: SettingsStrings.termsTitle,
              subtitle: SettingsStrings.termsSubtitle,
              trailing: const _Chevron(),
              onTap: onTerms,
            ),
            SettingsTile(
              icon: Icons.support_agent,
              iconColor: AppColors.onSurfaceVariant,
              title: SettingsStrings.supportTitle,
              subtitle: SettingsStrings.supportSubtitle,
              trailing: const _Chevron(),
              onTap: onSupport,
            ),
            SettingsTile(
              icon: Icons.info_outline,
              iconColor: AppColors.onSurfaceVariant,
              title: SettingsStrings.aboutTitle,
              subtitle: SettingsStrings.aboutSubtitle,
              trailing: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.pill,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    SettingsStrings.versionTag(AppInfo.version),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    // Mirrors in RTL so it points toward the reading direction.
    return Icon(Icons.chevron_right, color: AppColors.outlineVariant);
  }
}
