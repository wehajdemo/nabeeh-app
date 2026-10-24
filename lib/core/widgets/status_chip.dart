import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/dot.dart';

/// Semantic tone of a [StatusChip] (DESIGN.md → "Status Chips & Badges").
enum StatusTone { success, warning, danger, neutral }

class _TonePalette {
  const _TonePalette(this.background, this.foreground, this.dot);

  final Color background;
  final Color foreground;
  final Color dot;
}

/// Looked up on every build so it follows the current theme.
_TonePalette _paletteFor(StatusTone tone) => switch (tone) {
      StatusTone.success => _TonePalette(
          AppColors.secondaryContainer40,
          AppColors.onSecondaryContainer,
          AppColors.secondary,
        ),
      StatusTone.warning => _TonePalette(
          AppColors.tertiaryContainer15,
          AppColors.tertiary,
          AppColors.tertiary,
        ),
      StatusTone.danger => _TonePalette(
          AppColors.stateDangerBackground,
          AppColors.stateDanger,
          AppColors.stateDanger,
        ),
      StatusTone.neutral => _TonePalette(
          AppColors.surfaceContainer,
          AppColors.onSurfaceVariant,
          AppColors.outline,
        ),
    };

/// Pill with a leading dot, e.g. `● مكتمل`.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Dot(color: palette.dot, size: 4),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelXs.copyWith(color: palette.foreground),
            ),
          ],
        ),
      ),
    );
  }
}
