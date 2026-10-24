import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';

/// A selectable plan: radio, name, note and price.
class PlanOptionCard extends StatelessWidget {
  const PlanOptionCard({
    required this.title,
    required this.note,
    required this.price,
    required this.priceSuffix,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.ribbon,
    this.strikePrice,
  });

  final String title;
  final String note;

  /// Big number, e.g. `5.6`.
  final String price;

  /// Under the number, e.g. `ر.س / شهر` or `تجديد شهري`.
  final String priceSuffix;
  final bool isSelected;
  final VoidCallback onTap;

  /// Highlight label on the top corner ("وفر 38%").
  final String? ribbon;

  /// Crossed-out comparison price shown next to the title.
  final String? strikePrice;

  @override
  Widget build(BuildContext context) {
    final ribbonText = ribbon;
    return Semantics(
      button: true,
      selected: isSelected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          boxShadow: isSelected ? AppShadows.elevated : AppShadows.card,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      ribbonText == null ? AppSpacing.md : AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Radio(isSelected: isSelected),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: _Details(
                          title: title,
                          note: note,
                          strikePrice: strikePrice,
                        )),
                        const SizedBox(width: AppSpacing.sm),
                        _Price(price: price, suffix: priceSuffix),
                      ],
                    ),
                  ),
                  if (ribbonText != null)
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: _Ribbon(text: ribbonText),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 2,
          ),
        ),
        child: SizedBox.square(
          dimension: 20,
          child: isSelected
              ? Icon(Icons.check, size: 14, color: AppColors.onPrimary)
              : null,
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.title,
    required this.note,
    required this.strikePrice,
  });

  final String title;
  final String note;
  final String? strikePrice;

  @override
  Widget build(BuildContext context) {
    final strike = strikePrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (strike != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                strike,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.outline,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        Text(
          note,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.price, required this.suffix});

  final String price;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price,
          style: AppTypography.currencyStat.copyWith(color: AppColors.primary),
        ),
        Text(
          suffix,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(AppRadius.md),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 14,
              color: AppColors.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
