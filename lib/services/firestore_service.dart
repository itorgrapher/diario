import 'package:cloud_firestore/cloud_firestore.dart';

/// Formats a DateTime as the document id we use everywhere: yyyy-MM-dd
String dayId(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _entries(String uid) =>
      _db.collection('users').doc(uid).collection('entries');

  CollectionReference<Map<String, dynamic>> _daily(String uid) =>
      _db.collection('users').doc(uid).collection('daily');

  CollectionReference<Map<String, dynamic>> _habits(String uid) =>
      _db.collection('users').doc(uid).collection('habits');

  // ---------- Entries (text + trackers + gratitude + photos) ----------

  Future<void> saveEntry(String uid, DateTime date, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return _entries(uid).doc(dayId(date)).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getEntry(String uid, DateTime date) async {
    final snap = await _entries(uid).doc(dayId(date)).get();
    return snap.data();
  }

  Stream<Map<String, dynamic>?> watchEntry(String uid, DateTime date) {
    return _entries(uid).doc(dayId(date)).snapshots().map((s) => s.data());
  }

  /// Returns a map of day-of-month -> entry data for the given year/month.
  Future<Map<int, Map<String, dynamic>>> getMonthEntries(String uid, int year, int month) async {
    final prefix = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final snap = await _entries(uid)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$prefix-01')
        .where(FieldPath.documentId, isLessThanOrEqualTo: '$prefix-31')
        .get();
    final result = <int, Map<String, dynamic>>{};
    for (final doc in snap.docs) {
      final day = int.tryParse(doc.id.split('-').last);
      if (day != null) result[day] = doc.data();
    }
    return result;
  }

  // ---------- Daily extras (tasks / water / exercise) ----------

  Future<void> saveDaily(String uid, DateTime date, Map<String, dynamic> data) {
    return _daily(uid).doc(dayId(date)).set(data, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchDaily(String uid, DateTime date) {
    return _daily(uid).doc(dayId(date)).snapshots().map((s) => s.data());
  }

  Future<Map<int, Map<String, dynamic>>> getMonthDaily(String uid, int year, int month) async {
    final prefix = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final snap = await _daily(uid)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$prefix-01')
        .where(FieldPath.documentId, isLessThanOrEqualTo: '$prefix-31')
        .get();
    final result = <int, Map<String, dynamic>>{};
    for (final doc in snap.docs) {
      final day = int.tryParse(doc.id.split('-').last);
      if (day != null) result[day] = doc.data();
    }
    return result;
  }

  // ---------- Habits (custom streaks) ----------

  Stream<List<Map<String, dynamic>>> watchHabits(String uid) {
    return _habits(uid).orderBy('createdAt').snapshots().map(
          (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> addHabit(String uid, String name) {
    return _habits(uid).add({'name': name, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeHabit(String uid, String habitId) {
    return _habits(uid).doc(habitId).delete();
  }
}
