import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/appearance_mode.dart';
import 'package:rateby/features/settings/presentation/settings_strings.dart';

/// Short name of [mode], also shown on the Settings row.
String appearanceLabel(AppearanceMode mode) => switch (mode) {
      AppearanceMode.system => SettingsStrings.appearanceSystem,
      AppearanceMode.light => SettingsStrings.appearanceLight,
      AppearanceMode.dark => SettingsStrings.appearanceDark,
    };

IconData appearanceIcon(AppearanceMode mode) => switch (mode) {
      AppearanceMode.system => Icons.brightness_auto_outlined,
      AppearanceMode.light => Icons.light_mode_outlined,
      AppearanceMode.dark => Icons.dark_mode_outlined,
    };

/// Pick light, dark or system. Resolves to the choice, or `null` if dismissed.
Future<AppearanceMode?> showAppearanceSheet(
  BuildContext context, {
  required AppearanceMode current,
}) {
  return showAppBottomSheet<AppearanceMode>(
    context: context,
    builder: (_) => _AppearanceSheet(current: current),
  );
}

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet({required this.current});

  final AppearanceMode current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        const SheetHeader(
          title: SettingsStrings.appearanceTitle,
          subtitle: SettingsStrings.appearanceSheetSubtitle,
          icon: Icons.contrast,
        ),
        for (final mode in AppearanceMode.values)
          _ModeOption(
            mode: mode,
            selected: mode == current,
            onTap: () => Navigator.of(context).pop(mode),
          ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppearanceMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.tile,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondaryContainer40
                : AppColors.surfaceContainer,
            borderRadius: AppRadius.tile,
            border: Border.all(
              color: selected ? AppColors.secondary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: AppSpacing.cardMd,
            child: Row(
              children: [
                Icon(
                  appearanceIcon(mode),
                  color: selected
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appearanceLabel(mode),
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (mode == AppearanceMode.system)
                        Text(
                          SettingsStrings.appearanceSystemHint,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
