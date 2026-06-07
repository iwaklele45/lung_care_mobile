import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore reader/writer for the top-level `health_tracking` collection.
///
/// Uses a deterministic doc id `{uid}_{yyyy-MM-dd}` so each user can only
/// submit one check-in per day.
class CheckInRemoteDataSource {
  CheckInRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'health_tracking',
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

  DocumentReference<Map<String, dynamic>> get _todayDoc =>
      _firestore.collection('health_tracking').doc('${_uid}_$_todayKey');

  /// Whether the current user already submitted a check-in today.
  Future<bool> hasCheckedInToday() async {
    final snapshot = await _todayDoc.get();
    return snapshot.exists;
  }

  /// Returns today's check-in data, or null if not submitted yet.
  Future<Map<String, dynamic>?> getTodayCheckIn() async {
    final snapshot = await _todayDoc.get();
    return snapshot.data();
  }

  Future<void> addCheckIn({
    required Map<String, int> symptoms,
    required String notes,
  }) {
    final docId = '${_uid}_$_todayKey';
    return _todayDoc.set({
      'check_id': docId,
      'patient_id': _uid,
      'date': _todayKey,
      'additional_notes': notes,
      'symptoms': symptoms,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<int> getCheckInCount() async {
    final snapshot = await _firestore
        .collection('health_tracking')
        .where('patient_id', isEqualTo: _uid)
        .get();
    return snapshot.docs.length;
  }

  /// Returns all health_tracking documents for the current user, newest first.
  Future<List<Map<String, dynamic>>> getAllHealthTracking() async {
    final snapshot = await _firestore
        .collection('health_tracking')
        .where('patient_id', isEqualTo: _uid)
        .get();
    final list = snapshot.docs.map((doc) => doc.data()).toList();
    list.sort(
      (a, b) => (b['date'] as String).compareTo(a['date'] as String),
    );
    return list;
  }
}
