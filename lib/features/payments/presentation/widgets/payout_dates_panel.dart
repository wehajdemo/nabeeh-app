import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/domain/payout_program.dart';
import 'package:rateby/features/payments/presentation/payments_strings.dart';
import 'package:rateby/features/payments/presentation/payout_ui.dart';

/// Grey panel with the card's two key facts: dates on one side and either a
/// countdown (upcoming) or the next payment (already paid) on the other.
class PayoutDatesPanel extends StatelessWidget {
  const PayoutDatesPanel({required this.info, super.key});

  final PayoutInfo info;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.tile,
      ),
      child: Padding(
        padding: AppSpacing.cardSm,
        child: Row(
          children: [
            Expanded(child: _startSide()),
            Expanded(child: _endSide()),
          ],
        ),
      ),
    );
  }

  Widget _startSide() {
    if (info.status == PayoutStatus.paid) {
      return _Fact(
        label: PaymentsStrings.lastDeposit,
        value: PayoutDateFormat.full(info.lastPayout!),
        valueColor: AppColors.onSurface,
      );
    }
    if (info.isWindow) {
      return _Fact(
        label: PaymentsStrings.expectedWindow,
        value: PayoutDateFormat.window(info.nextPayout, info.windowEnd!),
        valueColor: AppColors.onSurface,
        caption: info.program.windowNote,
      );
    }
    final label = info.status == PayoutStatus.expected
        ? PaymentsStrings.expectedDate
        : info.program.kind == PayoutKind.governmentSalary
            ? PaymentsStrings.fixedDate
            : PaymentsStrings.payoutDate;
    return _Fact(
      label: label,
      value: PayoutDateFormat.full(info.nextPayout),
      valueColor: AppColors.onSurface,
      caption: info.wasShiftedForWeekend ? PaymentsStrings.weekendShifted : null,
    );
  }

  Widget _endSide() {
    if (info.status == PayoutStatus.paid) {
      return _Fact(
        label: PaymentsStrings.nextPayment,
        value: PayoutDateFormat.full(info.nextPayout),
        valueColor: AppColors.primary,
        caption: ArabicText.remainingDays(info.daysUntilNext),
        captionColor: AppColors.secondary,
        alignEnd: true,
      );
    }
    return _Countdown(info: info);
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    required this.valueColor,
    this.caption,
    this.captionColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? caption;
  /// Defaults to the muted outline color.
  final Color? captionColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final captionText = caption;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLg.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (captionText != null && captionText.isNotEmpty)
          Text(
            captionText,
            style: AppTypography.bodySm.copyWith(color: captionColor ?? AppColors.outline),
          ),
      ],
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.info});

  final PayoutInfo info;

  @override
  Widget build(BuildContext context) {
    final String number;
    final String unit;
    final String label;

    if (info.isWindow) {
      label = PaymentsStrings.remainingTime;
      if (info.daysUntilNext == 0) {
        number = PaymentsStrings.withinWindow;
        unit = '';
      } else {
        number = PaymentsStrings.dayRange(
          info.daysUntilNext,
          info.daysUntilWindowEnd ?? info.daysUntilNext,
        );
        unit = PaymentsStrings.daysLabel;
      }
    } else if (info.isToday) {
      label = PaymentsStrings.countdown;
      number = PaymentsStrings.arrivesToday;
      unit = '';
    } else {
      label = PaymentsStrings.countdown;
      number = '${info.daysUntilNext}';
      unit = info.daysUntilNext == 1
          ? PaymentsStrings.dayRemainingLabel
          : PaymentsStrings.daysRemainingLabel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              number,
              style: AppTypography.currencyStat.copyWith(
                color: AppColors.primary,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                unit,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
