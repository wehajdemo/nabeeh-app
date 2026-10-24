import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/presentation/upgrade_strings.dart';

/// Call to action, trial reassurance, restore link and legal footer.
class SubscribeFooter extends StatelessWidget {
  const SubscribeFooter({
    required this.onSubscribe,
    required this.onRestore,
    required this.isBusy,
    super.key,
    this.onTerms,
    this.onPrivacy,
    this.onSupport,
  });

  final VoidCallback onSubscribe;
  final VoidCallback onRestore;
  final bool isBusy;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final VoidCallback? onSupport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.gutterSm,
      children: [
        PrimaryButton(
          label: UpgradeStrings.subscribe(PlusPlan.trialDays),
          icon: Icons.bolt,
          isLoading: isBusy,
          onPressed: onSubscribe,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                UpgradeStrings.trialNote(PlusPlan.trialDays),
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: isBusy ? null : onRestore,
          icon: const Icon(Icons.restart_alt, size: 18),
          label: const Text(UpgradeStrings.restore),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, AppSizes.minTouchTarget),
            textStyle: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md,
          children: [
            _Link(label: UpgradeStrings.terms, onTap: onTerms),
            _Link(label: UpgradeStrings.privacy, onTap: onPrivacy),
            _Link(label: UpgradeStrings.support, onTap: onSupport),
          ],
        ),
        Text(
          UpgradeStrings.vatNote,
          textAlign: TextAlign.center,
          style: AppTypography.labelXs.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
