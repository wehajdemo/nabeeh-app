import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable clock. Override in tests to make date logic deterministic:
/// `clockProvider.overrideWithValue(() => DateTime(2026, 10, 22, 17))`.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
