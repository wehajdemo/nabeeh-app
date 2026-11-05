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
/// Asks first (so the provider's sheet never appears out of nowhere) with
/// one button per sign-in method, then opens that provider's sheet.
Future<bool> ensureSignedIn(
  BuildContext context,
  WidgetRef ref, {
  required SignInReason reason,
}) async {
  if (ref.read(accountUserProvider).valueOrNull != null) return true;

  final service = ref.read(accountServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  if (service.methods.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text(AccountStrings.signInFailed)),
    );
    return false;
  }

  final method = await showDialog<SignInMethod>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AccountStrings.signInTitle),
      content: Text(reason.body),
      actionsOverflowDirection: VerticalDirection.up,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AccountStrings.notNow),
        ),
        for (final method in service.methods)
          _MethodButton(
            method: method,
            onPressed: () => Navigator.pop(context, method),
          ),
      ],
    ),
  );
  if (method == null || !context.mounted) return false;

  try {
    final user = await service.signIn(method);
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

class _MethodButton extends StatelessWidget {
  const _MethodButton({required this.method, required this.onPressed});

  final SignInMethod method;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => switch (method) {
        // Apple's style: a black button with the Apple logo.
        SignInMethod.apple => FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            icon: const Icon(Icons.apple),
            label: const Text(AccountStrings.continueWithApple),
          ),
        SignInMethod.google => FilledButton(
            onPressed: onPressed,
            child: const Text(AccountStrings.continueWithGoogle),
          ),
      };
}
