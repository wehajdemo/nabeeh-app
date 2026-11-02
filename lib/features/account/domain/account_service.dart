import 'package:flutter/foundation.dart';

/// The signed-in person. Signing in is optional; it is required only to
/// subscribe, and it is what lets a subscription and the budget data follow
/// the person to a new phone.
@immutable
class AccountUser {
  const AccountUser({required this.uid, this.email, this.name});

  final String uid;
  final String? email;
  final String? name;
}

/// Sign-in boundary (Google account, through Firebase Auth).
abstract interface class AccountService {
  /// `null` while signed out.
  AccountUser? get currentUser;

  /// Emits the current user and every later change.
  Stream<AccountUser?> get changes;

  /// Opens Google's account picker. `null` when the person cancels.
  /// Throws [AccountException] when sign-in fails.
  Future<AccountUser?> signInWithGoogle();

  Future<void> signOut();
}

class AccountException implements Exception {
  const AccountException([this.message = 'Sign-in failed']);

  final String message;

  @override
  String toString() => 'AccountException: $message';
}

/// Where accounts do not exist (web, tests, builds without Firebase).
class NoAccountService implements AccountService {
  const NoAccountService();

  @override
  AccountUser? get currentUser => null;

  @override
  Stream<AccountUser?> get changes => const Stream.empty();

  @override
  Future<AccountUser?> signInWithGoogle() async =>
      throw const AccountException('Accounts are not available in this build');

  @override
  Future<void> signOut() async {}
}
