import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/money_formatter.dart';
import 'package:rateby/core/widgets/widgets.dart';

/// Confirmation shown for ~3 s after an expense is saved.
class SavedBanner extends StatelessWidget {
  const SavedBanner({required this.amount, super.key});

  final Money amount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: AppCard(
        color: AppColors.surfaceContainerHighest,
        shadows: AppShadows.elevated,
        child: Row(
          children: [
            IconBadge(
              icon: Icons.verified,
              background: AppColors.secondaryContainer,
              foreground: AppColors.onSecondaryContainer,
              size: 32,
              iconSize: 18,
              borderRadius: AppRadius.pill,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.savedTitle,
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppStrings.savedBody(MoneyFormatter.formatExact(amount)),
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
