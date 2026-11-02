import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rateby/features/upgrade/domain/billing_config.dart';
import 'package:rateby/features/upgrade/domain/plus_entitlement.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';
import 'package:rateby/features/upgrade/domain/subscription_verifier.dart';

/// Thrown when a purchase check is attempted without a Google sign-in.
class SignInRequiredException implements Exception {
  const SignInRequiredException();

  @override
  String toString() => 'SignInRequiredException';
}

/// Calls a Cloud Function by name with a JSON-like payload.
typedef CallableInvoker = Future<Map<String, Object?>> Function(
  String name,
  Map<String, Object?> data,
);

/// [SubscriptionVerifier] backed by the `syncEntitlement` Cloud Function.
class CloudFunctionsSubscriptionVerifier implements SubscriptionVerifier {
  CloudFunctionsSubscriptionVerifier({
    required CallableInvoker call,
    required Future<void> Function() ensureSignedIn,
  })  : _call = call,
        _ensureSignedIn = ensureSignedIn;

  /// Production wiring: the Google-signed-in Firebase user + the deployed
  /// function. Anonymous users are not accepted (subscriptions follow the
  /// Google account).
  factory CloudFunctionsSubscriptionVerifier.firebase() {
    final functions =
        FirebaseFunctions.instanceFor(region: BillingConfig.functionsRegion);
    return CloudFunctionsSubscriptionVerifier(
      ensureSignedIn: () async {
        final auth = FirebaseAuth.instance;
        final user = auth.currentUser;
        if (user == null || user.isAnonymous) {
          throw const SignInRequiredException();
        }
      },
      call: (name, data) async {
        final result = await functions.httpsCallable(name).call<Object?>(data);
        final body = result.data;
        if (body is! Map) {
          throw const FormatException('Unexpected billing response');
        }
        return Map<String, Object?>.from(body);
      },
    );
  }

  static const String functionName = 'syncEntitlement';

  final CallableInvoker _call;
  final Future<void> Function() _ensureSignedIn;

  @override
  Future<PlusEntitlement> verify({
    required String productId,
    required String purchaseToken,
  }) =>
      _sync({'productId': productId, 'purchaseToken': purchaseToken});

  @override
  Future<PlusEntitlement> refresh() => _sync(const {});

  Future<PlusEntitlement> _sync(Map<String, Object?> data) async {
    await _ensureSignedIn();
    return parse(await _call(functionName, data));
  }

  /// Reads the function's answer. Throws [FormatException] on anything
  /// unexpected, so a broken reply never grants Plus.
  static PlusEntitlement parse(Map<String, Object?> body) {
    final active = body['active'];
    if (active is! bool) {
      throw const FormatException('Billing response has no "active" flag');
    }
    final planName = body['plan'];
    final expires = body['expiresAtMs'];
    return PlusEntitlement(
      active: active,
      plan: PlusPlanType.values.where((p) => p.name == planName).firstOrNull,
      expiresAt:
          expires is num ? DateTime.fromMillisecondsSinceEpoch(expires.toInt()) : null,
    );
  }
}
