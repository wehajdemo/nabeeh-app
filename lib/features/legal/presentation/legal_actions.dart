import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/links/link_launcher.dart';
import 'package:rateby/features/legal/application/legal_providers.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';
import 'package:rateby/features/legal/presentation/legal_screen.dart';
import 'package:rateby/features/legal/presentation/legal_strings.dart';

/// Opens the privacy policy / terms / support page.
Future<void> openLegal(BuildContext context, LegalKind kind) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => LegalScreen(kind: kind)),
  );
}

/// Opens the mail app addressed to support; if there is none, shows the
/// address so the user can write from elsewhere.
Future<void> contactSupport(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final launcher = ref.read(linkLauncherProvider);
  String? email;
  try {
    email = (await ref.read(legalContentProvider.future)).supportEmail;
    final opened = await launcher.open(
      Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': LegalStrings.supportSubject},
      ),
    );
    if (opened) return;
  } on Object {
    // Fall through to the message below.
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          email == null
              ? LegalStrings.loadFailed
              : LegalStrings.mailFailed(email),
        ),
      ),
    );
}
