import 'package:flutter/material.dart';
import 'package:rateby/core/constants/app_strings.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/utils/arabic_text.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/budget/domain/entities/budget_health.dart';
import 'package:rateby/features/budget/presentation/budget_health_ui.dart';
import 'package:rateby/features/home/application/home_state.dart';
import 'package:rateby/features/home/presentation/widgets/budget_health_chip.dart';

/// Date line, greeting and the budget-health chip at the top of Home.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.today,
    required this.greeting,
    required this.userName,
    required this.health,
    super.key,
  });

  final DateTime today;
  final HomeGreeting greeting;
  final String userName;
  final BudgetHealth health;

  String get _greetingText => switch (greeting) {
        HomeGreeting.morning => AppStrings.greetingMorning,
        HomeGreeting.evening => AppStrings.greetingEvening,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Dot(color: health.accent, size: 8),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${AppStrings.todayPrefix} ${ArabicText.weekdayAndDate(today)}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '$_greetingText، $userName 👋',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        BudgetHealthChip(health: health),
      ],
    );
  }
}
