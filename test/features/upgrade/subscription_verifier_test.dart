import 'package:flutter_test/flutter_test.dart';
import 'package:rateby/features/upgrade/data/cloud_functions_subscription_verifier.dart';
import 'package:rateby/features/upgrade/domain/plus_plan.dart';

void main() {
  group('response parsing', () {
    test('reads an active yearly subscription', () {
      final e = CloudFunctionsSubscriptionVerifier.parse({
        'active': true,
        'plan': 'yearly',
        'expiresAtMs': 1795000000000,
      });
      expect(e.active, isTrue);
      expect(e.plan, PlusPlanType.yearly);
      expect(e.expiresAt, DateTime.fromMillisecondsSinceEpoch(1795000000000));
    });

    test('reads "no subscription"', () {
      final e = CloudFunctionsSubscriptionVerifier.parse({'active': false});
      expect(e.active, isFalse);
      expect(e.plan, isNull);
      expect(e.expiresAt, isNull);
    });

    test('anything malformed throws instead of granting Plus', () {
      expect(
        () => CloudFunctionsSubscriptionVerifier.parse({'plan': 'yearly'}),
        throwsFormatException,
      );
      expect(
        () => CloudFunctionsSubscriptionVerifier.parse({'active': 'yes'}),
        throwsFormatException,
      );
    });
  });

  group('calls', () {
    test('signs in first, then calls syncEntitlement with the token', () async {
      final log = <String>[];
      Map<String, Object?>? sent;
      final verifier = CloudFunctionsSubscriptionVerifier(
        ensureSignedIn: () async => log.add('signin'),
        call: (name, data) async {
          log.add(name);
          sent = data;
          return {'active': true, 'plan': 'monthly'};
        },
      );

      final e = await verifier.verify(
        productId: 'rateby_plus_monthly',
        purchaseToken: 'abc',
      );

      expect(log, ['signin', 'syncEntitlement']);
      expect(sent, {'productId': 'rateby_plus_monthly', 'purchaseToken': 'abc'});
      expect(e.plan, PlusPlanType.monthly);
    });

    test('refresh sends no token', () async {
      Map<String, Object?>? sent;
      final verifier = CloudFunctionsSubscriptionVerifier(
        ensureSignedIn: () async {},
        call: (name, data) async {
          sent = data;
          return {'active': false};
        },
      );

      await verifier.refresh();

      expect(sent, isEmpty);
    });

    test('a sign-in failure propagates (no entitlement is granted)', () {
      final verifier = CloudFunctionsSubscriptionVerifier(
        ensureSignedIn: () async => throw Exception('no auth'),
        call: (name, data) async => {'active': true},
      );
      expect(verifier.refresh(), throwsException);
    });
  });
}
