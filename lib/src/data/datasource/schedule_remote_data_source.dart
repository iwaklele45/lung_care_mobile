import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';

/// Firestore CRUD for the top-level `schedules` collection (scoped by `uid`).
class ScheduleRemoteDataSource {
  ScheduleRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('schedules');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'schedules',
        message: 'Pengguna belum login.',
      );
    }
    return uid;
  }

  Stream<List<Medication>> watchSchedules() {
    return _collection.where('uid', isEqualTo: _uid).snapshots().map((snapshot) {
      final meds = snapshot.docs
          .map((doc) => Medication.fromMap(doc.id, doc.data()))
          .toList();
      // Sort client-side to avoid requiring a composite index.
      meds.sort((a, b) {
        final ta = a.times.isEmpty ? 0 : a.times.first.hour * 60 + a.times.first.minute;
        final tb = b.times.isEmpty ? 0 : b.times.first.hour * 60 + b.times.first.minute;
        return ta - tb;
      });
      return meds;
    });
  }

  Future<void> addSchedule(Medication med) =>
      _collection.add({...med.toMap(), 'uid': _uid});

  Future<void> updateSchedule(Medication med) =>
      _collection.doc(med.id).update(med.toMap());

  Future<void> deleteSchedule(String id) => _collection.doc(id).delete();
}
