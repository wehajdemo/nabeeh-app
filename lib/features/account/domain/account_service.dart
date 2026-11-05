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

/// Ways to sign in. Apple's guidelines require "Sign in with Apple" on the
/// iPhone wherever another account sign-in is offered.
enum SignInMethod { apple, google }

/// Sign-in boundary (Apple or Google account, through Firebase Auth).
abstract interface class AccountService {
  /// `null` while signed out.
  AccountUser? get currentUser;

  /// Emits the current user and every later change.
  Stream<AccountUser?> get changes;

  /// The sign-in methods this build offers, in the order to show them.
  /// Empty where accounts do not exist.
  List<SignInMethod> get methods;

  /// Opens the provider's sign-in sheet. `null` when the person cancels.
  /// Throws [AccountException] when sign-in fails.
  Future<AccountUser?> signIn(SignInMethod method);

  Future<void> signOut();

  /// Deletes the account itself. The provider may ask the person to confirm
  /// who they are first. Returns `false` when they cancel that step.
  /// Throws [AccountException] when the deletion fails.
  Future<bool> deleteAccount();
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
  List<SignInMethod> get methods => const [];

  @override
  Future<AccountUser?> signIn(SignInMethod method) async =>
      throw const AccountException('Accounts are not available in this build');

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> deleteAccount() async => false;
}
