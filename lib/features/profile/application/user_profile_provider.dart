import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rateby/features/profile/domain/user_profile.dart';

/// Placeholder until auth / onboarding stores the real name.
final userProfileProvider = Provider<UserProfile>(
  (ref) => const UserProfile(displayName: 'ريان'),
);
