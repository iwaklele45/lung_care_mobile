import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Simple data model for a medication schedule item.
class MedicationScheduleItem {
  const MedicationScheduleItem({
    required this.id,
    required this.name,
    required this.time,
    required this.dosage,
    required this.status,
  });

  final String id;
  final String name;
  final String time;
  final String dosage;

  /// 'pending' | 'taken' | 'missed'
  final String status;
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeFetchSchedulesRequested>(_onFetchSchedules);
    on<HomeCheckInDoseRequested>(_onCheckInDose);
  }

  Future<void> _onFetchSchedules(
    HomeFetchSchedulesRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // TODO(Week2): Replace with real Firestore fetch via use case.
      await Future.delayed(const Duration(milliseconds: 800));

      final schedules = [
        const MedicationScheduleItem(
          id: 'sched_1',
          name: 'Rifampicin + Isoniazid',
          time: '09:00 AM',
          dosage: '600mg + 300mg',
          status: 'pending',
        ),
        const MedicationScheduleItem(
          id: 'sched_2',
          name: 'Pyrazinamide',
          time: '12:30 PM',
          dosage: '500mg',
          status: 'pending',
        ),
        const MedicationScheduleItem(
          id: 'sched_3',
          name: 'Ethambutol',
          time: '07:00 AM',
          dosage: '400mg',
          status: 'taken',
        ),
      ];

      emit(
        HomeLoaded(
          userName: 'Jane',
          treatmentDay: 45,
          totalDays: 180,
          progressPercent: 0.25,
          nextDoseTime: '09:00 AM',
          nextDoseName: 'Rifampicin + Isoniazid',
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
    // TODO(Week2): Call Firestore write use case here.
    // Optimistically re-fetch after check-in.
    emit(HomeCheckInSuccess());
    add(HomeFetchSchedulesRequested());
  }
}
