import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/widgets/widgets.dart';
import 'package:rateby/features/account/application/account_providers.dart';
import 'package:rateby/features/account/domain/account_service.dart';
import 'package:rateby/features/account/presentation/account_strings.dart';

/// Why the app is asking the person to sign in.
enum SignInReason {
  subscribe(AccountStrings.signInBodySubscribe),
  restore(AccountStrings.signInBodyRestore),
  optional(AccountStrings.signInBodyOptional);

  const SignInReason(this.body);
  final String body;
}

/// Makes sure somebody is signed in. Returns `true` when someone is.
///
/// Asks first (so Google's picker never appears out of nowhere), then opens
/// the Google account picker.
Future<bool> ensureSignedIn(
  BuildContext context,
  WidgetRef ref, {
  required SignInReason reason,
}) async {
  if (ref.read(accountUserProvider).valueOrNull != null) return true;

  final agreed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AccountStrings.signInTitle),
      content: Text(reason.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AccountStrings.notNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(AccountStrings.continueWithGoogle),
        ),
      ],
    ),
  );
  if (agreed != true || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    final user = await ref.read(accountServiceProvider).signInWithGoogle();
    if (user != null && context.mounted) {
      AppToast.show(context, AccountStrings.signedIn);
    }
    return user != null;
  } on AccountException {
    messenger.showSnackBar(
      const SnackBar(content: Text(AccountStrings.signInFailed)),
    );
    return false;
  }
}
