import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/features/export/domain/budget_report.dart';

/// Expenses as CSV that opens correctly in Excel (UTF-8 with BOM, Arabic
/// headers, Western digits).
abstract final class ExpensesCsv {
  static const String bom = '\uFEFF';
  static const List<String> header = ['التاريخ', 'الوقت', 'المبلغ (ر.س)', 'البيان'];

  static String build(BudgetReport report) {
    final rows = <List<String>>[
      header,
      for (final e in report.expenses)
        [
          _date(e.createdAt),
          _time(e.createdAt),
          MoneyFormatter.formatExact(e.amount).replaceAll(',', ''),
          e.note ?? '',
        ],
    ];
    return '$bom${rows.map((r) => r.map(_cell).join(',')).join('\r\n')}\r\n';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _date(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  /// Quotes a cell when it contains a separator, quote or line break.
  static String _cell(String value) {
    final needsQuotes = value.contains(RegExp(r'[",\r\n]'));
    return needsQuotes ? '"${value.replaceAll('"', '""')}"' : value;
  }
}
