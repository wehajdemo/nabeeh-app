import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/features/payments/application/payments_state.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/presentation/payments_strings.dart';

extension PayoutKindUi on PayoutKind {
  IconData get icon => switch (this) {
        PayoutKind.governmentSalary => Icons.account_balance_outlined,
        PayoutKind.citizenAccount => Icons.groups_outlined,
        PayoutKind.socialSecurity => Icons.family_restroom,
        PayoutKind.pension => Icons.elderly,
        PayoutKind.studentStipend => Icons.school_outlined,
        PayoutKind.other => Icons.payments_outlined,
      };

  /// Icon shown in front of the card's footer remark.
  IconData get noteIcon => switch (this) {
        PayoutKind.governmentSalary => Icons.schedule,
        PayoutKind.citizenAccount => Icons.info_outline,
        PayoutKind.socialSecurity => Icons.event_available_outlined,
        PayoutKind.pension => Icons.swap_horiz,
        PayoutKind.studentStipend => Icons.help_outline,
        PayoutKind.other => Icons.info_outline,
      };
}

extension PayoutFilterUi on PayoutFilter {
  String label(int totalCount) => switch (this) {
        PayoutFilter.all => PaymentsStrings.filterAll(totalCount),
        PayoutFilter.government => PaymentsStrings.filterGovernment,
        PayoutFilter.support => PaymentsStrings.filterSupport,
        PayoutFilter.retireesAndStudents =>
          PaymentsStrings.filterRetireesStudents,
      };
}

extension PayoutStatusUi on PayoutStatus {
  String get label => switch (this) {
        PayoutStatus.confirmed => PaymentsStrings.confirmed,
        PayoutStatus.expected => PaymentsStrings.expected,
        PayoutStatus.paid => PaymentsStrings.paid,
      };

  Color get background => switch (this) {
        PayoutStatus.confirmed => AppColors.primaryFixed,
        PayoutStatus.expected => AppColors.tertiaryFixed,
        PayoutStatus.paid => AppColors.surfaceContainerHigh,
      };

  Color get foreground => switch (this) {
        PayoutStatus.confirmed => AppColors.onPrimaryFixed,
        PayoutStatus.expected => AppColors.onTertiaryFixed,
        PayoutStatus.paid => AppColors.onSurface,
      };
}

/// Date formatting for payout cards (Gregorian only).
abstract final class PayoutDateFormat {
  /// `27 أكتوبر 2026`
  static String full(DateTime d) => '${d.day} ${ArabicText.month(d)} ${d.year}';

  /// `25 - 28 أكتوبر 2026`, or both months if the window spans two.
  static String window(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return PaymentsStrings.dateRange(
        start.day,
        end.day,
        ArabicText.month(end),
        end.year,
      );
    }
    return '${full(start)} - ${full(end)}';
  }
}
