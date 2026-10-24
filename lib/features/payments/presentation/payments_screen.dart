import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/theme/app_colors.dart';
import 'package:rateby/core/theme/app_typography.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/payments/application/payments_controller.dart';
import 'package:rateby/features/payments/application/payments_state.dart';
import 'package:rateby/features/payments/presentation/payments_strings.dart';
import 'package:rateby/features/payments/presentation/payout_ui.dart';
import 'package:rateby/features/payments/presentation/widgets/payments_banner.dart';
import 'package:rateby/features/payments/presentation/widgets/payout_card.dart';
import 'package:rateby/features/payments/presentation/widgets/weekend_rule_card.dart';

/// Payout dates tab: salaries, support programs, pensions and stipends.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsControllerProvider);
    final filter = ref.watch(payoutFilterProvider);

    return payments.when(
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorRetryView(
        onRetry: () => ref.invalidate(paymentsControllerProvider),
      ),
      data: (state) => _PaymentsBody(
        state: state,
        filter: filter,
        onFilterChanged: ref.read(payoutFilterProvider.notifier).select,
        onToggleAlert: (id) => _toggleAlert(context, ref, id),
        onRefresh: () => _refresh(context, ref),
      ),
    );
  }
}

Future<void> _toggleAlert(
  BuildContext context,
  WidgetRef ref,
  String programId,
) async {
  final permitted =
      await ref.read(paymentsControllerProvider.notifier).toggleAlert(programId);
  if (!permitted && context.mounted) {
    AppToast.show(context, PaymentsStrings.notificationsBlocked, isError: true);
  }
}

Future<void> _refresh(BuildContext context, WidgetRef ref) async {
  final ok = await ref.read(paymentsControllerProvider.notifier).refreshSchedule();
  if (!ok && context.mounted) {
    AppToast.show(context, PaymentsStrings.refreshFailed, isError: true);
  }
}

class _PaymentsBody extends StatelessWidget {
  const _PaymentsBody({
    required this.state,
    required this.filter,
    required this.onFilterChanged,
    required this.onToggleAlert,
    required this.onRefresh,
  });

  final PaymentsState state;
  final PayoutFilter filter;
  final ValueChanged<PayoutFilter> onFilterChanged;
  final ValueChanged<String> onToggleAlert;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final visible = state.visible(filter);
    final highlightedId = state.nextDueId(filter);

    return ScreenBody(
      onRefresh: onRefresh,
      children: [
        PaymentsBanner(updatedAt: state.scheduleUpdatedAt),
        ChoiceChipBar<PayoutFilter>(
          options: {
            for (final f in PayoutFilter.values) f: f.label(state.totalCount),
          },
          selected: filter,
          onSelected: onFilterChanged,
        ),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                PaymentsStrings.emptyFilter,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final item in visible)
            PayoutCard(
              key: ValueKey(item.id),
              item: item,
              isHighlighted: item.id == highlightedId,
              onToggleAlert: () => onToggleAlert(item.id),
            ),
        const WeekendRuleCard(),
      ],
    );
  }
}
