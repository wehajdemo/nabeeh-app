import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:rateby/firebase_options.dart';

/// Starts Firebase and returns Firestore, or `null` if it is not configured
/// or cannot start. The app must work without it (offline-first), so this
/// never throws.
Future<FirebaseFirestore?> initFirestore() async {
  try {
    // Hot restart (or native auto-init on Android) may have started it already.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return FirebaseFirestore.instance;
  } on Object catch (error) {
    debugPrint('Firebase unavailable, using local schedule only: $error');
    return null;
  }
}
