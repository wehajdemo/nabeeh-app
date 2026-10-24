import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/money/money.dart';
import 'package:rateby/features/add_expense/domain/amount_input.dart';
import 'package:rateby/features/ads/application/ads_providers.dart';
import 'package:rateby/features/budget/application/budget_providers.dart';

enum AddExpenseStatus { idle, saving, saved, failed }

/// Raw form state owned by [AddExpenseController]. Anything derived from
/// it (hints, remaining limit…) lives in `AddExpenseViewState`.
@immutable
class AddExpenseState {
  const AddExpenseState({
    this.input = const AmountInput.empty(),
    this.status = AddExpenseStatus.idle,
    this.showValidationError = false,
    this.lastSaved,
    this.note = '',
  });

  final AmountInput input;
  final AddExpenseStatus status;

  /// Set when "save" is pressed with a zero amount; cleared on next input.
  final bool showValidationError;

  /// Amount confirmed by the most recent successful save.
  final Money? lastSaved;

  /// Optional description typed by the user (empty = none).
  final String note;

  AddExpenseState copyWith({
    AmountInput? input,
    AddExpenseStatus? status,
    bool? showValidationError,
    Money? lastSaved,
    String? note,
  }) {
    return AddExpenseState(
      input: input ?? this.input,
      status: status ?? this.status,
      showValidationError: showValidationError ?? this.showValidationError,
      lastSaved: lastSaved ?? this.lastSaved,
      note: note ?? this.note,
    );
  }
}

/// Keypad + save logic for the "log expense" screen.
class AddExpenseController extends AutoDisposeNotifier<AddExpenseState> {
  static const Duration _savedBannerDuration = Duration(milliseconds: 3200);

  Timer? _bannerTimer;
  bool _disposed = false;

  @override
  AddExpenseState build() {
    ref.onDispose(() {
      _disposed = true;
      _bannerTimer?.cancel();
    });
    return const AddExpenseState();
  }

  void pressDigit(String digit) => _edit((i) => i.pressDigit(digit));
  void pressDecimalPoint() => _edit((i) => i.pressDecimalPoint());
  void backspace() => _edit((i) => i.backspace());
  void setNote(String value) => state = state.copyWith(note: value);
  void selectPreset(int riyals) => _edit((i) => i.preset(riyals));

  void _edit(AmountInput Function(AmountInput) change) {
    if (state.status == AddExpenseStatus.saving) return;
    state = state.copyWith(
      input: change(state.input),
      showValidationError: false,
    );
  }

  Future<void> save() async {
    if (state.status == AddExpenseStatus.saving) return;

    final amount = state.input.amount;
    if (!amount.isPositive) {
      state = state.copyWith(showValidationError: true);
      return;
    }

    state = state.copyWith(status: AddExpenseStatus.saving);
    try {
      await ref.read(logExpenseUseCaseProvider)(amount, note: state.note);
      ref.read(adCoordinatorProvider).noteExpenseSaved();
      if (_disposed) return;

      // Reset the keypad for the next entry; keep the confirmation.
      state = AddExpenseState(
        status: AddExpenseStatus.saved,
        lastSaved: amount,
      );
      _bannerTimer?.cancel();
      _bannerTimer = Timer(_savedBannerDuration, _hideSavedBanner);
    } on Object {
      if (_disposed) return;
      state = state.copyWith(status: AddExpenseStatus.failed);
    }
  }

  void _hideSavedBanner() {
    if (_disposed || state.status != AddExpenseStatus.saved) return;
    state = AddExpenseState(input: state.input);
  }
}

final addExpenseControllerProvider =
    AutoDisposeNotifierProvider<AddExpenseController, AddExpenseState>(
  AddExpenseController.new,
);
