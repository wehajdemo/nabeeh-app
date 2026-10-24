import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a web page or mail composer outside the app.
abstract interface class LinkLauncher {
  /// `true` if something handled the link.
  Future<bool> open(Uri uri);
}

/// Default (tests, web preview): opens nothing.
class NoopLinkLauncher implements LinkLauncher {
  const NoopLinkLauncher();

  @override
  Future<bool> open(Uri uri) async => false;
}

/// Overridden in `main()` with the `url_launcher` implementation.
final linkLauncherProvider = Provider<LinkLauncher>(
  (ref) => const NoopLinkLauncher(),
);
