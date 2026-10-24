import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/export/application/export_service.dart';
import 'package:rateby/features/export/presentation/export_strings.dart';

/// Lets the user pick PDF or CSV. Resolves to `null` when dismissed.
Future<ExportFormat?> showExportSheet(BuildContext context) {
  return showAppBottomSheet<ExportFormat>(
    context: context,
    builder: (_) => const _ExportOptions(),
  );
}

class _ExportOptions extends StatelessWidget {
  const _ExportOptions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        const SheetHeader(
          title: ExportStrings.sheetTitle,
          subtitle: ExportStrings.sheetSubtitle,
          icon: Icons.ios_share,
        ),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.picture_as_pdf_outlined,
              title: ExportStrings.pdfTitle,
              subtitle: ExportStrings.pdfSubtitle,
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.outlineVariant,
              ),
              onTap: () => Navigator.of(context).pop(ExportFormat.pdf),
            ),
            SettingsTile(
              icon: Icons.table_chart_outlined,
              iconColor: AppColors.secondary,
              title: ExportStrings.csvTitle,
              subtitle: ExportStrings.csvSubtitle,
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.outlineVariant,
              ),
              onTap: () => Navigator.of(context).pop(ExportFormat.csv),
            ),
          ],
        ),
      ],
    );
  }
}
