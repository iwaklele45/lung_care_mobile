import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/src/data/datasource/check_in_remote_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/dose_check_in_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';

part 'home_event.dart';
part 'home_state.dart';

String _displayName(String fullName) {
  const prefixes = {'muhammad', 'muhamad', 'mohammad', 'mohamad', 'muh'};
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length > 1 && prefixes.contains(parts.first.toLowerCase())) {
    return parts[1];
  }
  return parts.first;
}

class MedicationScheduleItem {
  const MedicationScheduleItem({
    required this.id,
    required this.scheduleId,
    required this.timeIndex,
    required this.name,
    required this.time,
    required this.dosage,
    required this.status,
  });

  final String id;
  final String scheduleId;
  final int timeIndex;
  final String name;
  final String time;
  final String dosage;
  final String status;
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    CheckInRemoteDataSource? checkInDataSource,
    ScheduleRemoteDataSource? scheduleDataSource,
    DoseCheckInDataSource? doseCheckInDataSource,
  })  : _checkInDataSource = checkInDataSource ?? CheckInRemoteDataSource(),
        _scheduleDataSource = scheduleDataSource ?? ScheduleRemoteDataSource(),
        _doseCheckInDataSource =
            doseCheckInDataSource ?? DoseCheckInDataSource(),
        super(HomeInitial()) {
    on<HomeFetchSchedulesRequested>(_onFetchSchedules);
    on<HomeCheckInDoseRequested>(_onCheckInDose);
  }

  final CheckInRemoteDataSource _checkInDataSource;
  final ScheduleRemoteDataSource _scheduleDataSource;
  final DoseCheckInDataSource _doseCheckInDataSource;

  static const int totalDays = 180;

  Future<void> _onFetchSchedules(
    HomeFetchSchedulesRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final userDoc = uid == null
          ? null
          : await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullName = (userDoc?.data()?['name'] as String?) ?? 'User';
      final userName = _displayName(fullName);

      final treatmentDay = await _checkInDataSource.getCheckInCount();
      final progressPercent = treatmentDay / totalDays;

      final medications = await _scheduleDataSource.fetchSchedules();
      final checkedInKeys = await _doseCheckInDataSource.getCheckedInKeysToday();

      final schedules = medications.expand<MedicationScheduleItem>((med) {
        if (med.times.isEmpty) {
          final key = '${med.id}_0';
          return [
            MedicationScheduleItem(
              id: key,
              scheduleId: med.id ?? '',
              timeIndex: 0,
              name: med.name,
              time: '--:--',
              dosage: med.dose,
              status: checkedInKeys.contains(key) ? 'taken' : 'pending',
            ),
          ];
        }
        return med.times.asMap().entries.map((entry) {
          final key = '${med.id}_${entry.key}';
          final timeOfDay = entry.value;
          final hours = timeOfDay.hour;
          final minutes = timeOfDay.minute;
          final ampm = hours >= 12 ? 'PM' : 'AM';
          final displayHour = hours == 0
              ? 12
              : hours > 12
                  ? hours - 12
                  : hours;
          final timeStr =
              '$displayHour:${minutes.toString().padLeft(2, '0')} $ampm';
          return MedicationScheduleItem(
            id: key,
            scheduleId: med.id ?? '',
            timeIndex: entry.key,
            name: med.name,
            time: timeStr,
            dosage: med.dose,
            status: checkedInKeys.contains(key) ? 'taken' : 'pending',
          );
        });
      }).toList();

      final nextPending = schedules.any((s) => s.status == 'pending')
          ? schedules.firstWhere((s) => s.status == 'pending')
          : null;

      emit(
        HomeLoaded(
          userName: userName,
          treatmentDay: treatmentDay,
          totalDays: totalDays,
          progressPercent: progressPercent,
          nextDoseTime: nextPending?.time ?? '--:--',
          nextDoseName: nextPending?.name ?? 'No pending dose',
          schedules: schedules,
        ),
      );
    } catch (_) {
      emit(HomeError('Gagal memuat jadwal. Silakan coba lagi.'));
    }
  }

  Future<void> _onCheckInDose(
    HomeCheckInDoseRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final item = event.item;
      await _doseCheckInDataSource.checkInDose(
        scheduleId: item.scheduleId,
        timeIndex: item.timeIndex,
      );
      await _scheduleDataSource.decrementAmount(item.scheduleId);
      add(HomeFetchSchedulesRequested());
    } catch (_) {
      emit(HomeError('Gagal mencatat dosis. Silakan coba lagi.'));
    }
  }
}
