import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/payments/presentation/payments_strings.dart';
import 'package:rateby/features/payments/presentation/payout_ui.dart';

/// Trust note explaining where the dates come from.
class PaymentsBanner extends StatelessWidget {
  const PaymentsBanner({super.key, this.updatedAt});

  /// When an admin last published the dates; `null` shows the generic
  /// "indicative schedule" badge.
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 40,
              child: Icon(
                Icons.verified_outlined,
                size: 22,
                color: AppColors.onPrimaryFixed,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        PaymentsStrings.bannerTitle,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InfoPill(
                      label: updatedAt == null
                          ? PaymentsStrings.bannerBadge
                          : PaymentsStrings.bannerUpdated(
                              PayoutDateFormat.full(updatedAt!),
                            ),
                      background: AppColors.surfaceContainerLowest,
                      foreground: AppColors.secondary,
                      textStyle: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ),
                  ],
                ),
                Text(
                  PaymentsStrings.bannerBody,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
