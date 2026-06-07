import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_service.dart';
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

  Future<List<Medication>> fetchSchedules() async {
    final snapshot = await _collection.where('uid', isEqualTo: _uid).get();
    final meds = snapshot.docs
        .map((doc) => Medication.fromMap(doc.id, doc.data()))
        .toList();
    meds.sort((a, b) {
      final ta = a.times.isEmpty
          ? 0
          : a.times.first.hour * 60 + a.times.first.minute;
      final tb = b.times.isEmpty
          ? 0
          : b.times.first.hour * 60 + b.times.first.minute;
      return ta - tb;
    });
    return meds;
  }

  Stream<List<Medication>> watchSchedules() {
    return _collection.where('uid', isEqualTo: _uid).snapshots().map((
      snapshot,
    ) {
      final meds = snapshot.docs
          .map((doc) => Medication.fromMap(doc.id, doc.data()))
          .toList();
      meds.sort((a, b) {
        final ta = a.times.isEmpty
            ? 0
            : a.times.first.hour * 60 + a.times.first.minute;
        final tb = b.times.isEmpty
            ? 0
            : b.times.first.hour * 60 + b.times.first.minute;
        return ta - tb;
      });
      return meds;
    });
  }

  Future<void> addSchedule(Medication med) async {
    await _collection.add({...med.toMap(), 'uid': _uid});
    await _syncMedicationReminders();
  }

  Future<void> updateSchedule(Medication med) async {
    await _collection.doc(med.id).update(med.toMap());
    await _syncMedicationReminders();
  }

  Future<void> deleteSchedule(String id) async {
    await _collection.doc(id).delete();
    await _syncMedicationReminders();
  }

  /// Decrements the integer value of `amount` by 1 for the given schedule doc.
  /// Uses a Firestore transaction to avoid lost updates.
  Future<void> decrementAmount(String scheduleId) async {
    final ref = _collection.doc(scheduleId);
    return _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) return;
      final current = snapshot.data()?['amount'];
      final parsed = int.tryParse(current?.toString() ?? '') ?? 0;
      if (parsed <= 0) return;
      tx.update(ref, {'amount': (parsed - 1).toString()});
    });
  }

  Future<void> _syncMedicationReminders() async {
    final meds = await fetchSchedules();
    await NotificationService.instance.syncMedicationReminders(meds);
  }
}
