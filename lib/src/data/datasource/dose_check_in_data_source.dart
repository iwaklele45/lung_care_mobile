import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoseCheckInDataSource {
  DoseCheckInDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'dose_check_ins',
        message: 'Pengguna belum login.',
      );
    }
    return uid;
  }

  String get _todayKey {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  /// Returns the set of composite keys "{scheduleId}_{timeIndex}" that have
  /// been checked in today.
  Future<Set<String>> getCheckedInKeysToday() async {
    final snapshot = await _firestore
        .collection('dose_check_ins')
        .where('patient_id', isEqualTo: _uid)
        .where('date', isEqualTo: _todayKey)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['check_key'] as String)
        .toSet();
  }

  /// Records a dose check-in for a specific schedule time-slot today.
  ///
  /// [scheduleId] is the Firestore document ID in the `schedules` collection.
  /// [timeIndex] is the 0-based index into the schedule's `times` list.
  Future<void> checkInDose({
    required String scheduleId,
    required int timeIndex,
  }) {
    final key = '${scheduleId}_$timeIndex';
    final docId = '${_uid}_${scheduleId}_${timeIndex}_$_todayKey';
    return _firestore.collection('dose_check_ins').doc(docId).set({
      'dose_check_id': docId,
      'patient_id': _uid,
      'schedule_id': scheduleId,
      'time_index': timeIndex,
      'date': _todayKey,
      'check_key': key,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Returns all dose check-in documents for the current user, newest first.
  Future<List<Map<String, dynamic>>> getAllCheckIns() async {
    final snapshot = await _firestore
        .collection('dose_check_ins')
        .where('patient_id', isEqualTo: _uid)
        .get();
    final list = snapshot.docs.map((doc) => doc.data()).toList();
    list.sort(
      (a, b) => (b['date'] as String).compareTo(a['date'] as String),
    );
    return list;
  }

  /// Returns a set of scheduleIds that have at least one dose checked-in today.
  Future<Set<String>> getCheckedInScheduleIdsToday() async {
    final snapshot = await _firestore
        .collection('dose_check_ins')
        .where('patient_id', isEqualTo: _uid)
        .where('date', isEqualTo: _todayKey)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['schedule_id'] as String)
        .toSet();
  }
}