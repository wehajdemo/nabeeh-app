import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/core/links/link_launcher.dart';
import 'package:rateby/features/legal/application/legal_providers.dart';

/// `flutter test` runs from the package root.
String readLegalJson() => File('assets/legal/legal.json').readAsStringSync();

Override legalFromDisk([String Function()? read]) =>
    legalSourceProvider.overrideWithValue(
      () async => (read ?? readLegalJson)(),
    );

/// Records the links the app tried to open.
class RecordingLinkLauncher implements LinkLauncher {
  RecordingLinkLauncher({this.opens = true});

  bool opens;
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return opens;
  }
}
