import { readFileSync } from 'node:fs';
import {
  Environment,
  SignedDataVerifier,
  VerificationException,
  VerificationStatus,
} from '@apple/app-store-server-library';
import { ServiceError } from './errors.mjs';

const ROOT_CERTS = [
  readFileSync(new URL('../certs/AppleRootCA-G3.cer', import.meta.url)),
];

/**
 * Checks StoreKit 2 signed data (JWS) against Apple's root certificate.
 * No App Store Connect key is needed: the signature itself is the proof.
 *
 * Sandbox data (TestFlight, App Review) is accepted as well as production;
 * production needs the app's numeric Apple ID.
 *
 * @param {{ bundleId: string, appAppleId?: number }} options
 */
export function createAppleVerifier({ bundleId, appAppleId }) {
  const verifiers = [
    ...(appAppleId
      ? [new SignedDataVerifier(ROOT_CERTS, true, Environment.PRODUCTION, bundleId, appAppleId)]
      : []),
    new SignedDataVerifier(ROOT_CERTS, true, Environment.SANDBOX, bundleId),
  ];

  async function firstValid(decode) {
    let last;
    for (const verifier of verifiers) {
      try {
        return await decode(verifier);
      } catch (error) {
        if (!(error instanceof VerificationException)) throw error;
        last = error;
        // Wrong environment: the next verifier may accept it.
        if (error.status === VerificationStatus.INVALID_ENVIRONMENT) continue;
        break;
      }
    }
    // FAILURE is ours (for example Apple's revocation check unreachable).
    if (last?.status === VerificationStatus.FAILURE) throw last;
    throw new ServiceError('invalid-argument', 'Unknown App Store purchase.');
  }

  return {
    verifyTransaction: (jws) => firstValid((v) => v.verifyAndDecodeTransaction(jws)),
    verifyNotification: (payload) =>
      firstValid((v) => v.verifyAndDecodeNotification(payload)),
  };
}
