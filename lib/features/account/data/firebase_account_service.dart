import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rateby/features/account/domain/account_service.dart';

/// [AccountService] backed by Google Sign-In + Firebase Auth.
class FirebaseAccountService implements AccountService {
  FirebaseAccountService({FirebaseAuth? auth, GoogleSignIn? google})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = google ??
            GoogleSignIn(
              scopes: const ['email'],
              // iOS needs the OAuth client id of the iOS app (Firebase console →
              // Authentication → Google → set; see docs/RELEASE_CHECKLIST.md).
              clientId: defaultTargetPlatform == TargetPlatform.iOS &&
                      _iosClientId.isNotEmpty
                  ? _iosClientId
                  : null,
            );

  static const String _iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  /// Anonymous users (from older builds) count as signed out.
  static AccountUser? _map(User? user) => user == null || user.isAnonymous
      ? null
      : AccountUser(uid: user.uid, email: user.email, name: user.displayName);

  @override
  AccountUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AccountUser?> get changes => _auth.authStateChanges().map(_map);

  @override
  Future<AccountUser?> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) return null;
      final tokens = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return _map(result.user);
    } on Object catch (error) {
      throw AccountException('$error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _google.signOut();
    } on Object {
      // Signing out of Firebase below is what matters.
    }
    await _auth.signOut();
  }
}
