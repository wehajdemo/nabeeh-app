import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rateby/features/account/domain/account_service.dart';

/// [AccountService] backed by Firebase Auth: Sign in with Apple (iPhone) and
/// Google Sign-In.
class FirebaseAccountService implements AccountService {
  FirebaseAccountService({FirebaseAuth? auth, GoogleSignIn? google})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = google ??
            GoogleSignIn(
              scopes: const ['email'],
              // iOS needs the OAuth client id of the iOS app (Firebase console →
              // Authentication → Google → set; see docs/RELEASE_CHECKLIST.md).
              clientId: _isIos && _iosClientId.isNotEmpty ? _iosClientId : null,
            );

  static const String _iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  /// Anonymous users (from older builds) count as signed out.
  static AccountUser? _map(User? user) => user == null || user.isAnonymous
      ? null
      : AccountUser(uid: user.uid, email: user.email, name: user.displayName);

  static AppleAuthProvider _appleProvider() => AppleAuthProvider()
    ..addScope('email')
    ..addScope('name');

  /// The person closed the provider's sheet.
  static bool _cancelled(FirebaseAuthException error) =>
      error.code.contains('cancel');

  @override
  AccountUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AccountUser?> get changes => _auth.authStateChanges().map(_map);

  @override
  List<SignInMethod> get methods => _isIos
      ? [
          SignInMethod.apple,
          // Google on the iPhone needs its iOS client id and URL scheme.
          if (_iosClientId.isNotEmpty) SignInMethod.google,
        ]
      : const [SignInMethod.google];

  @override
  Future<AccountUser?> signIn(SignInMethod method) async {
    try {
      final result = switch (method) {
        SignInMethod.apple => await _auth.signInWithProvider(_appleProvider()),
        SignInMethod.google => await _signInWithGoogle(),
      };
      return _map(result?.user);
    } on FirebaseAuthException catch (error) {
      if (_cancelled(error)) return null;
      throw AccountException('$error');
    } on Object catch (error) {
      throw AccountException('$error');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    final credential = await _googleCredential();
    if (credential == null) return null;
    return _auth.signInWithCredential(credential);
  }

  Future<OAuthCredential?> _googleCredential() async {
    final account = await _google.signIn();
    if (account == null) return null;
    final tokens = await account.authentication;
    return GoogleAuthProvider.credential(
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
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

  @override
  Future<bool> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return true;
    final providers = user.providerData.map((p) => p.providerId).toSet();
    try {
      // Firebase deletes only after a recent sign-in, so confirm first.
      if (providers.contains('apple.com')) {
        final confirmed = await user.reauthenticateWithProvider(_appleProvider());
        // Apple asks apps to revoke its tokens when the account goes away.
        final code = confirmed.additionalUserInfo?.authorizationCode;
        if (code != null) {
          try {
            await _auth.revokeTokenWithAuthorizationCode(code);
          } on Object {
            // Needs Apple's key in the Firebase console; the deletion matters more.
          }
        }
      } else if (providers.contains('google.com')) {
        final credential = await _googleCredential();
        if (credential == null) return false;
        await user.reauthenticateWithCredential(credential);
      }
      await user.delete();
    } on FirebaseAuthException catch (error) {
      if (_cancelled(error)) return false;
      throw AccountException('$error');
    } on Object catch (error) {
      throw AccountException('$error');
    }
    try {
      await _google.disconnect();
    } on Object {
      // Not signed in with Google on this phone.
    }
    return true;
  }
}
