import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/legal/domain/legal_content.dart';

/// Where the legal JSON comes from. Tests override it.
final legalSourceProvider = Provider<Future<String> Function()>(
  (ref) => () => rootBundle.loadString('assets/legal/legal.json'),
);

final legalContentProvider = FutureProvider<LegalContent>((ref) async {
  final source = await ref.watch(legalSourceProvider)();
  return LegalContent.parse(source);
});
