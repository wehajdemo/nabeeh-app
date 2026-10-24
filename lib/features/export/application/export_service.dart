import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/providers/clock_provider.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';
import 'package:rateby/features/export/data/pdf_report_generator.dart';
import 'package:rateby/features/export/data/share_plus_file_sharer.dart';
import 'package:rateby/features/export/domain/budget_report.dart';
import 'package:rateby/features/export/domain/csv_builder.dart';
import 'package:rateby/features/export/domain/file_sharer.dart';
import 'package:rateby/features/upgrade/application/entitlement_controller.dart';
import 'package:rateby/features/upgrade/domain/plus_gate.dart';

enum ExportFormat { pdf, csv }

/// Thrown when there is nothing to export yet (onboarding not finished).
class NothingToExportException implements Exception {
  const NothingToExportException();

  @override
  String toString() => 'NothingToExportException';
}

typedef ReportFonts = ({ByteData regular, ByteData bold});

/// Loads the Arabic fonts embedded in the PDF. Override in tests.
final reportFontsProvider = Provider<Future<ReportFonts> Function()>(
  (ref) => () async => (
        regular: await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
        bold: await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'),
      ),
);

final fileSharerProvider = Provider<FileSharer>(
  (ref) => const SharePlusFileSharer(),
);

/// Builds the report from the stored data and shares it. Plus only, or one export per rewarded video.
class ExportService {
  ExportService(this._ref);

  final Ref _ref;

  /// [rewarded]: the user watched a rewarded video, which unlocks this one
  /// export without Plus.
  Future<void> export(ExportFormat format, {bool rewarded = false}) async {
    if (!rewarded && !_ref.read(isPlusProvider)) throw const PlusRequiredException(PlusFeature.export);

    final profile = await _ref.read(profileProvider.future);
    if (profile == null) throw const NothingToExportException();
    final goals = await _ref.read(goalsProvider.future);
    final expenses = await _ref.read(budgetRepositoryProvider).loadExpenses();
    final now = _ref.read(clockProvider)();

    final report = BudgetReportBuilder.build(
      profile: profile,
      goals: goals,
      expenses: expenses,
      now: now,
    );
    final stamp = '${now.year}-${_two(now.month)}-${_two(now.day)}';
    final sharer = _ref.read(fileSharerProvider);

    switch (format) {
      case ExportFormat.pdf:
        final fonts = await _ref.read(reportFontsProvider)();
        final bytes = await PdfReportGenerator.generate(
          report,
          regularFont: fonts.regular,
          boldFont: fonts.bold,
        );
        await sharer.share(
          bytes: bytes,
          fileName: 'rateby-report-$stamp.pdf',
          mimeType: 'application/pdf',
        );
      case ExportFormat.csv:
        await sharer.share(
          bytes: Uint8List.fromList(utf8.encode(ExpensesCsv.build(report))),
          fileName: 'rateby-expenses-$stamp.csv',
          mimeType: 'text/csv',
        );
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

final exportServiceProvider = Provider<ExportService>(ExportService.new);
