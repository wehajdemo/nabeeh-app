import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';

/// Reads the schedule published by the admin dashboard:
/// `config/payout_schedule` → `{programs: [...], updatedAt: Timestamp}`.
class FirestorePayoutSource implements PayoutRemoteSource {
  const FirestorePayoutSource(this._firestore);

  static const String documentPath = 'config/payout_schedule';

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, Object?>?> fetch() async {
    // Force the server so a stale on-device Firestore cache is never used
    // as "fresh"; offline throws and the repository keeps its own cache.
    final snapshot = await _firestore
        .doc(documentPath)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    final data = snapshot.data();
    if (data == null) return null;

    final updatedAt = data['updatedAt'];
    return {
      ...data,
      'updatedAt':
          updatedAt is Timestamp ? updatedAt.millisecondsSinceEpoch : null,
    };
  }
}
