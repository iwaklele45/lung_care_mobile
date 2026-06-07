import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/presentation/bloc/home/home_bloc.dart';

import '../../../mocks/mock_data_sources.dart';

void main() {
  late HomeBloc homeBloc;
  late MockCheckInRemoteDataSource mockCheckIn;
  late MockDoseCheckInDataSource mockDoseCheckIn;
  late MockScheduleRemoteDataSource mockSchedule;

  setUp(() {
    mockCheckIn = MockCheckInRemoteDataSource();
    mockDoseCheckIn = MockDoseCheckInDataSource();
    mockSchedule = MockScheduleRemoteDataSource();

    homeBloc = HomeBloc(
      checkInDataSource: mockCheckIn,
      scheduleDataSource: mockSchedule,
      doseCheckInDataSource: mockDoseCheckIn,
    );
  });

  tearDown(() {
    homeBloc.close();
  });

  setUpAll(() {
    registerFallbackValue(
      const MedicationScheduleItem(
        id: 'fallback',
        scheduleId: 'fallback',
        timeIndex: 0,
        name: 'Fallback',
        time: '00:00',
        dosage: '0mg',
        status: 'pending',
      ),
    );
  });

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      expect(homeBloc.state, isA<HomeInitial>());
    });

    group('HomeCheckInDoseRequested', () {
      blocTest<HomeBloc, HomeState>(
        'calls checkInDose and decrementAmount on success',
        build: () {
          when(() => mockDoseCheckIn.checkInDose(
                scheduleId: any(named: 'scheduleId'),
                timeIndex: any(named: 'timeIndex'),
              )).thenAnswer((_) async {});
          when(() => mockSchedule.decrementAmount(any()))
              .thenAnswer((_) async {});
          // Mock for the subsequent HomeFetchSchedulesRequested
          when(() => mockCheckIn.getCheckInCount())
              .thenAnswer((_) async => 10);
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getCheckedInKeysToday())
              .thenAnswer((_) async => {});
          return homeBloc;
        },
        act: (bloc) {
          // Seed with a loaded state first
          bloc.emit(HomeLoaded(
            userName: 'User',
            treatmentDay: 10,
            totalDays: 180,
            progressPercent: 10 / 180,
            nextDoseTime: '08:00',
            nextDoseName: 'Paracetamol',
            schedules: const [],
          ));
          bloc.add(HomeCheckInDoseRequested(
            item: const MedicationScheduleItem(
              id: 'med-1_0',
              scheduleId: 'med-1',
              timeIndex: 0,
              name: 'Paracetamol',
              time: '08:00',
              dosage: '500mg',
              status: 'pending',
            ),
          ));
        },
        verify: (bloc) {
          verify(() => mockDoseCheckIn.checkInDose(
                scheduleId: 'med-1',
                timeIndex: 0,
              )).called(1);
          verify(() => mockSchedule.decrementAmount('med-1')).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits [HomeError] when checkInDose fails',
        build: () {
          when(() => mockDoseCheckIn.checkInDose(
                scheduleId: any(named: 'scheduleId'),
                timeIndex: any(named: 'timeIndex'),
              )).thenThrow(Exception('Network error'));
          return homeBloc;
        },
        act: (bloc) => bloc.add(HomeCheckInDoseRequested(
          item: const MedicationScheduleItem(
            id: 'med-1_0',
            scheduleId: 'med-1',
            timeIndex: 0,
            name: 'Paracetamol',
            time: '08:00',
            dosage: '500mg',
            status: 'pending',
          ),
        )),
        expect: () => [
          isA<HomeError>(),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [HomeError] when decrementAmount fails',
        build: () {
          when(() => mockDoseCheckIn.checkInDose(
                scheduleId: any(named: 'scheduleId'),
                timeIndex: any(named: 'timeIndex'),
              )).thenAnswer((_) async {});
          when(() => mockSchedule.decrementAmount(any()))
              .thenThrow(Exception('Network error'));
          return homeBloc;
        },
        act: (bloc) => bloc.add(HomeCheckInDoseRequested(
          item: const MedicationScheduleItem(
            id: 'med-1_0',
            scheduleId: 'med-1',
            timeIndex: 0,
            name: 'Paracetamol',
            time: '08:00',
            dosage: '500mg',
            status: 'pending',
          ),
        )),
        expect: () => [
          isA<HomeError>(),
        ],
      );
    });

    group('MedicationScheduleItem', () {
      test('has correct properties', () {
        const item = MedicationScheduleItem(
          id: 'med-1_0',
          scheduleId: 'med-1',
          timeIndex: 0,
          name: 'Paracetamol',
          time: '08:00',
          dosage: '500mg',
          status: 'pending',
        );

        expect(item.id, 'med-1_0');
        expect(item.scheduleId, 'med-1');
        expect(item.timeIndex, 0);
        expect(item.name, 'Paracetamol');
        expect(item.time, '08:00');
        expect(item.dosage, '500mg');
        expect(item.status, 'pending');
        expect(item.timeOfDay, isNull);
      });

      test('can have timeOfDay', () {
        const item = MedicationScheduleItem(
          id: 'med-1_0',
          scheduleId: 'med-1',
          timeIndex: 0,
          name: 'Paracetamol',
          time: '08:00',
          dosage: '500mg',
          status: 'pending',
          timeOfDay: TimeOfDay(hour: 8, minute: 0),
        );

        expect(item.timeOfDay, const TimeOfDay(hour: 8, minute: 0));
      });
    });
  });
}
