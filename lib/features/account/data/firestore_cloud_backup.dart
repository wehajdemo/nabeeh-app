import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rateby/features/account/domain/cloud_backup.dart';

/// Stores the backup at `users/{uid}/backup/latest`. Firestore rules allow
/// only that user (signed in with Google) to read or write it.
class FirestoreCloudBackup implements CloudBackup {
  FirestoreCloudBackup(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('users').doc(uid).collection('backup').doc('latest');

  @override
  Future<CloudBackupDoc?> fetch(String uid) async {
    final snap = await _ref(uid).get();
    final data = snap.data();
    if (data == null) return null;
    final payload = data['payload'];
    final updated = data['updatedAtMs'];
    if (payload is! String || updated is! int) return null;
    return CloudBackupDoc(
      payload: payload,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updated),
    );
  }

  @override
  Future<void> push(String uid, String payload) => _ref(uid).set({
        'payload': payload,
        'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
        'schema': 1,
      });

  @override
  Future<void> delete(String uid) => _ref(uid).delete();
}
