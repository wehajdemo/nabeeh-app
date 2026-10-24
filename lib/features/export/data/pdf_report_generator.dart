import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/export/domain/budget_report.dart';

/// Renders a [BudgetReport] as an Arabic (right-to-left) A4 PDF.
abstract final class PdfReportGenerator {
  static const PdfColor _emerald = PdfColor.fromInt(0xFF004328);
  static const PdfColor _mint = PdfColor.fromInt(0xFFA9F3C5);
  static const PdfColor _surface = PdfColor.fromInt(0xFFF2F3FF);
  static const PdfColor _muted = PdfColor.fromInt(0xFF404942);

  static const String _currency = 'ر.س';

  static Future<Uint8List> generate(
    BudgetReport report, {
    required ByteData regularFont,
    required ByteData boldFont,
  }) async {
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(regularFont),
      bold: pw.Font.ttf(boldFont),
    );
    final document = pw.Document(
      title: 'كشف الميزانية — نبيه',
      author: 'نبيه',
      theme: theme,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _title(report),
          pw.SizedBox(height: 16),
          _summary(report),
          pw.SizedBox(height: 18),
          if (report.commitments.isNotEmpty) ...[
            _heading('الالتزامات الثابتة'),
            _table(
              context,
              headers: const ['البند', 'المبلغ'],
              rows: [
                for (final c in report.commitments) [c.title, _money(c.amount)],
                ['الإجمالي', _money(report.commitmentsTotal)],
              ],
            ),
            pw.SizedBox(height: 18),
          ],
          if (report.goals.isNotEmpty) ...[
            _heading('الأهداف الادخارية'),
            _table(
              context,
              headers: const ['الهدف', 'المدّخر', 'المستهدف', 'الإنجاز', 'شهرياً'],
              rows: [
                for (final g in report.goals)
                  [
                    g.title,
                    _money(g.saved),
                    _money(g.target),
                    '${g.percent}%',
                    _money(g.monthly),
                  ],
              ],
            ),
            pw.SizedBox(height: 18),
          ],
          _heading('مصروفات الدورة الحالية'),
          if (report.days.isEmpty)
            pw.Text('لا توجد مصروفات مسجلة في هذه الدورة.')
          else
            _table(
              context,
              headers: const ['اليوم', 'عدد العمليات', 'المجموع'],
              rows: [
                for (final d in report.days)
                  [_date(d.date), '${d.count}', _money(d.total)],
              ],
            ),
          pw.SizedBox(height: 18),
          pw.Text(
            'أُنشئ هذا الكشف من بيانات مسجلة على جهازك في تطبيق نبيه بتاريخ ${_date(report.generatedAt)}. '
            'الأرقام تقديرية للمساعدة في التخطيط وليست كشف حساب بنكي.',
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );

    return document.save();
  }

  // ── pieces ──────────────────────────────────────────────────────────────

  static pw.Widget _title(BudgetReport r) => pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: _emerald,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'كشف الميزانية الشهرية',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'الدورة من ${_date(r.cycleStart)} إلى ${_date(r.cycleEnd)}',
              style: const pw.TextStyle(fontSize: 11, color: _mint),
            ),
          ],
        ),
      );

  static pw.Widget _summary(BudgetReport r) => pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: _surface,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          children: [
            _kv('الراتب الصافي', _money(r.netSalary)),
            _kv('الالتزامات الثابتة', _money(r.commitmentsTotal)),
            _kv('استقطاع الأهداف', _money(r.goalsMonthlyTotal)),
            _kv('المتاح للصرف في الدورة', _money(r.freeToSpend), bold: true),
            pw.Divider(color: _mint),
            _kv('الحد اليومي', _money(r.dailyLimit), bold: true),
            _kv('المصروف في الدورة', _money(r.spentInCycle)),
            _kv('المتبقي في الدورة', _money(r.remainingInCycle), bold: true),
            _kv('مصروف اليوم', _money(r.spentToday)),
          ],
        ),
      );

  static pw.Widget _kv(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: 12,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );
  }

  static pw.Widget _heading(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: _emerald,
          ),
        ),
      );

  static pw.Widget _table(
    pw.Context context, {
    required List<String> headers,
    required List<List<String>> rows,
  }) =>
      pw.TableHelper.fromTextArray(
        context: context,
        headers: headers,
        data: rows,
        headerStyle: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: _emerald),
        cellStyle: const pw.TextStyle(fontSize: 10),
        cellAlignment: pw.Alignment.centerRight,
        headerAlignment: pw.Alignment.centerRight,
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        oddRowDecoration: const pw.BoxDecoration(color: _surface),
      );

  static String _money(Money m) => '${MoneyFormatter.format(m)} $_currency';

  static String _date(DateTime d) => '${d.day} ${ArabicText.month(d)} ${d.year}';
}
