import 'package:rateby/core/links/link_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// [LinkLauncher] over `url_launcher`.
class UrlLauncherLinkLauncher implements LinkLauncher {
  const UrlLauncherLinkLauncher();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
