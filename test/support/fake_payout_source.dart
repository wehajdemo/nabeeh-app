import 'package:rateby/features/payments/domain/payout_schedule_repository.dart';

/// Scriptable stand-in for Firestore.
class FakePayoutSource implements PayoutRemoteSource {
  FakePayoutSource({this.doc, this.error});

  Map<String, Object?>? doc;
  Object? error;
  int calls = 0;

  @override
  Future<Map<String, Object?>?> fetch() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return doc;
  }
}

/// A valid dashboard document with the given programs.
Map<String, Object?> scheduleDoc(
  List<Map<String, Object?>> programs, {
  int updatedAt = 1760000000000,
}) =>
    {'updatedAt': updatedAt, 'programs': programs};

Map<String, Object?> programDoc({
  String id = 'p1',
  String title = 'برنامج',
  String category = 'government',
  int day = 15,
  Object? windowEndDay,
  Object? active,
}) =>
    {
      'id': id,
      'title': title,
      'category': category,
      'dayOfMonth': day,
      if (windowEndDay != null) 'windowEndDay': windowEndDay,
      if (active != null) 'active': active,
    };
