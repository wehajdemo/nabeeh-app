import 'package:flutter/material.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_shadows.dart';
import 'package:rateby/core/theme/app_spacing.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/features/budget/presentation/budget_strings.dart';

/// Payday selection: three common dates plus a custom 1–31 slider.
class PaydayPicker extends StatefulWidget {
  const PaydayPicker({
    required this.selectedDay,
    required this.onSelected,
    super.key,
  });

  final int selectedDay;
  final ValueChanged<int> onSelected;

  @override
  State<PaydayPicker> createState() => _PaydayPickerState();
}

class _Preset {
  const _Preset(this.day, this.title, this.note);

  final int day;
  final String title;
  final String note;
}

const List<_Preset> _presets = [
  _Preset(27, BudgetStrings.payday27Title, BudgetStrings.payday27Note),
  _Preset(1, BudgetStrings.payday1Title, BudgetStrings.payday1Note),
  _Preset(25, BudgetStrings.payday25Title, BudgetStrings.payday25Note),
];

class _PaydayPickerState extends State<PaydayPicker> {
  late bool _customOpen = !_isPreset(widget.selectedDay);

  static bool _isPreset(int day) => _presets.any((p) => p.day == day);

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.gutterSm,
      children: [
        for (final preset in _presets)
          _OptionCard(
            badge: preset.day.toString().padLeft(2, '0'),
            title: preset.title,
            subtitle: preset.note,
            isSelected: widget.selectedDay == preset.day,
            isDefault: preset.day == 27,
            onTap: () {
              setState(() => _customOpen = false);
              widget.onSelected(preset.day);
            },
          ),
        _CustomDayCard(
          day: widget.selectedDay,
          isOpen: _customOpen,
          isSelected: !_isPreset(widget.selectedDay),
          onToggle: () => setState(() => _customOpen = !_customOpen),
          onChanged: widget.onSelected,
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDefault,
    required this.onTap,
  });

  final String badge;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            width: 2,
          ),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Ink(
            decoration: const BoxDecoration(
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.card,
            ),
            child: Padding(
              padding: AppSpacing.cardMd,
              child: Row(
                children: [
                  _NumberTile(text: badge, isSelected: isSelected),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: AppTypography.labelLg.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const _DefaultTag(),
                            ],
                          ],
                        ),
                        Text(
                          subtitle,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RadioMark(isSelected: isSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.text, required this.isSelected});

  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: SizedBox.square(
        dimension: 52,
        child: Center(
          child: Text(
            text,
            style: AppTypography.headlineSm.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultTag extends StatelessWidget {
  const _DefaultTag();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          BudgetStrings.defaultTag,
          style: AppTypography.labelXs.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 28,
        child: isSelected
            ? Icon(Icons.check, size: 18, color: AppColors.onPrimary)
            : null,
      ),
    );
  }
}

class _CustomDayCard extends StatelessWidget {
  const _CustomDayCard({
    required this.day,
    required this.isOpen,
    required this.isSelected,
    required this.onToggle,
    required this.onChanged,
  });

  final int day;
  final bool isOpen;
  final bool isSelected;
  final VoidCallback onToggle;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
        border: Border.all(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: AppSpacing.cardMd,
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.card,
                        ),
                        child: SizedBox.square(
                          dimension: 52,
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              BudgetStrings.customDayTitle,
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              BudgetStrings.customDayNote,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isOpen ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.outline,
                      ),
                    ],
                  ),
                ),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            BudgetStrings.selectedDay,
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            BudgetStrings.dayOfMonth(day),
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primaryContainer,
                          inactiveTrackColor: AppColors.surfaceContainerHigh,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary40,
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Slider(
                            value: day.toDouble(),
                            min: 1,
                            max: 31,
                            divisions: 30,
                            label: '$day',
                            onChanged: (v) => onChanged(v.round()),
                          ),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final tick in const [1, 10, 20, 31])
                              Text(
                                '$tick',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
