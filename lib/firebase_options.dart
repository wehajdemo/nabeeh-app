import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase project `rateby-app-sa` (Android, iOS and web). These keys are
/// not secrets; access is enforced by Firestore rules.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => ios,
      _ => android,
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0iKdHknvNSSTbtzZYa5_qNYdrIg9CVWo',
    appId: '1:587906024162:android:c3f6e1e2ea7f20b35714bb',
    messagingSenderId: '587906024162',
    projectId: 'rateby-app-sa',
    storageBucket: 'rateby-app-sa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwG2lnCCYCwZanhKznJLiJr6yFAAT2P2g',
    appId: '1:587906024162:ios:c820a441136c07b15714bb',
    messagingSenderId: '587906024162',
    projectId: 'rateby-app-sa',
    storageBucket: 'rateby-app-sa.firebasestorage.app',
    iosBundleId: 'com.rateby.rateby',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcd9dEwNiq_voZvvCuaXP8JBaDXVRtlqI',
    appId: '1:587906024162:web:3b5b72b23107bf515714bb',
    messagingSenderId: '587906024162',
    projectId: 'rateby-app-sa',
    authDomain: 'rateby-app-sa.firebaseapp.com',
    storageBucket: 'rateby-app-sa.firebasestorage.app',
  );
}
