import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/payments/application/payments_state.dart';
import 'package:rateby/features/payments/domain/payout_info.dart';
import 'package:rateby/features/payments/presentation/payout_ui.dart';
import 'package:rateby/features/payments/presentation/widgets/alert_toggle_button.dart';
import 'package:rateby/features/payments/presentation/widgets/payout_dates_panel.dart';

/// One payout program. The nearest upcoming one is [isHighlighted] and also
/// shows how far we are through the current cycle.
class PayoutCard extends StatelessWidget {
  const PayoutCard({
    required this.item,
    required this.isHighlighted,
    required this.onToggleAlert,
    super.key,
  });

  final PayoutItem item;
  final bool isHighlighted;
  final VoidCallback onToggleAlert;

  PayoutInfo get _info => item.info;

  @override
  Widget build(BuildContext context) {
    final program = _info.program;
    final showMeter = isHighlighted && !_info.isWindow;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.gutterSm,
        children: [
          Row(
            children: [
              IconBadge(
                icon: program.kind.icon,
                background: isHighlighted
                    ? AppColors.primary
                    : AppColors.surfaceContainer,
                foreground: isHighlighted
                    ? AppColors.onPrimary
                    : AppColors.primary,
                size: 48,
                iconSize: 26,
                borderRadius: AppRadius.card,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      program.provider,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(status: _info.status),
            ],
          ),
          PayoutDatesPanel(info: _info),
          if (showMeter)
            AppProgressBar(
              value: _info.cycleProgress,
              height: 8,
              fill: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondary],
              ),
            ),
          Row(
            children: [
              Icon(
                program.kind.noteIcon,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  program.note,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AlertToggleButton(
                isOn: item.alertEnabled,
                onPressed: onToggleAlert,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PayoutStatus status;

  @override
  Widget build(BuildContext context) {
    return InfoPill(
      label: status.label,
      background: status.background,
      foreground: status.foreground,
      icon: status == PayoutStatus.paid ? Icons.check_circle : null,
      iconColor: AppColors.secondary,
      leading: status == PayoutStatus.confirmed
          ? Dot(color: AppColors.primary)
          : null,
      textStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
