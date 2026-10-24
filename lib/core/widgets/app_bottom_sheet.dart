import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// Opens a rounded modal sheet that lifts above the keyboard and scrolls when
/// the content is taller than the screen.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surfaceContainerLowest,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: AppRadius.pill,
                  ),
                  child: const SizedBox(width: 48, height: 6),
                ),
              ),
              AppSpacing.gapMd,
              builder(sheetContext),
            ],
          ),
        ),
      );
    },
  );
}

/// Title row used at the top of every sheet.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    required this.title,
    required this.icon,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 40,
            child: Icon(icon, size: 22, color: AppColors.onPrimaryFixed),
          ),
        ),
        const SizedBox(width: AppSpacing.gutterSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.close, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
