import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/export/application/export_service.dart';
import 'package:rateby/features/export/presentation/export_sheet.dart';
import 'package:rateby/features/export/presentation/export_strings.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';
import 'package:rateby/features/upgrade/presentation/plus_prompt.dart';

enum _FreeChoice { watchAd, upgrade }

/// Whole export interaction: Plus check → choose format → build → share.
/// Free users on a build with ads can watch a rewarded video to export once;
/// otherwise they are sent to the Upgrade tab.
Future<void> runExportFlow(BuildContext context, WidgetRef ref) async {
  var rewarded = false;
  if (!ref.read(isPlusProvider)) {
    if (!ref.read(showAdsProvider)) {
      promptUpgrade(context, ref, ExportStrings.plusRequired);
      return;
    }
    final choice = await _askFreeChoice(context);
    if (choice == null || !context.mounted) return;
    if (choice == _FreeChoice.upgrade) {
      promptUpgrade(context, ref, ExportStrings.plusRequired);
      return;
    }
    rewarded = await ref.read(adCoordinatorProvider).showRewarded();
    if (!context.mounted) return;
    if (!rewarded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ExportStrings.adUnavailable)),
      );
      return;
    }
  }

  final format = await showExportSheet(context);
  if (format == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(exportServiceProvider).export(format, rewarded: rewarded);
  } on PlusRequiredException {
    messenger.showSnackBar(
      const SnackBar(content: Text(ExportStrings.plusRequired)),
    );
  } on NothingToExportException {
    messenger.showSnackBar(
      const SnackBar(content: Text(ExportStrings.nothingToExport)),
    );
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text(ExportStrings.failed)),
    );
  }
}

Future<_FreeChoice?> _askFreeChoice(BuildContext context) {
  return showDialog<_FreeChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(ExportStrings.watchTitle),
      content: const Text(ExportStrings.watchBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _FreeChoice.upgrade),
          child: const Text(ExportStrings.upgradeAction),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _FreeChoice.watchAd),
          child: const Text(ExportStrings.watchAction),
        ),
      ],
    ),
  );
}
