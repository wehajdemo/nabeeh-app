import 'package:flutter/foundation.dart';

/// One backup of the person's budget data, as stored in their account.
@immutable
class CloudBackupDoc {
  const CloudBackupDoc({required this.payload, required this.updatedAt});

  /// The same JSON the app keeps on the device.
  final String payload;
  final DateTime updatedAt;
}

/// Server-side copy of the budget data, keyed by the signed-in user.
abstract interface class CloudBackup {
  Future<CloudBackupDoc?> fetch(String uid);
  Future<void> push(String uid, String payload);
  Future<void> delete(String uid);
}

/// Where backups do not exist (web, tests, builds without Firebase).
class NoCloudBackup implements CloudBackup {
  const NoCloudBackup();

  @override
  Future<CloudBackupDoc?> fetch(String uid) async => null;
  @override
  Future<void> push(String uid, String payload) async {}
  @override
  Future<void> delete(String uid) async {}
}
