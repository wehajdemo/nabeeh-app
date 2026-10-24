import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({required this.displayName});

  final String displayName;
}
