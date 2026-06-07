import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/presentation/bloc/history/history_bloc.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';

import '../../../mocks/mock_data_sources.dart';

void main() {
  late HistoryBloc historyBloc;
  late MockDoseCheckInDataSource mockDoseCheckIn;
  late MockCheckInRemoteDataSource mockCheckIn;
  late MockScheduleRemoteDataSource mockSchedule;

  setUp(() {
    mockDoseCheckIn = MockDoseCheckInDataSource();
    mockCheckIn = MockCheckInRemoteDataSource();
    mockSchedule = MockScheduleRemoteDataSource();

    historyBloc = HistoryBloc(
      doseCheckInDataSource: mockDoseCheckIn,
      checkInDataSource: mockCheckIn,
      scheduleDataSource: mockSchedule,
    );
  });

  tearDown(() {
    historyBloc.close();
  });

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  group('HistoryBloc', () {
    test('initial state is HistoryInitial', () {
      expect(historyBloc.state, isA<HistoryInitial>());
    });

    group('HistoryFetchRequested', () {
      blocTest<HistoryBloc, HistoryState>(
        'emits [HistoryLoading, HistoryLoaded] when fetch succeeds',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchRequested(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryLoaded>(),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'emits [HistoryLoading, HistoryError] when fetch fails',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenThrow(Exception('Network error'));
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchRequested(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryError>(),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'emits HistoryLoaded with correct calendar days',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchRequested(
          year: 2026,
          month: 6,
        )),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<HistoryLoaded>());
          final loaded = state as HistoryLoaded;
          expect(loaded.displayYear, 2026);
          expect(loaded.displayMonth, 6);
          expect(loaded.monthLabel, 'Juni 2026');
          expect(loaded.calendarDays, isNotEmpty);
        },
      );

      blocTest<HistoryBloc, HistoryState>(
        'emits HistoryLoaded with dose check-in data',
        build: () {
          when(() => mockSchedule.fetchSchedules()).thenAnswer((_) async => [
                Medication(
                  id: 'med-1',
                  name: 'Paracetamol',
                  amount: '30',
                  type: 'Tablet',
                  dose: '500mg',
                  frequency: '1x sehari',
                  capsuleColor: 'Putih',
                  times: const [TimeOfDay(hour: 8, minute: 0)],
                  reminder: true,
                ),
              ]);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => [
                    {
                      'schedule_id': 'med-1',
                      'time_index': 0,
                      'date': '2026-06-01',
                    },
                  ]);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchRequested(
          year: 2026,
          month: 6,
        )),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<HistoryLoaded>());
          final loaded = state as HistoryLoaded;
          expect(loaded.doseCheckIns, isNotEmpty);
        },
      );

      blocTest<HistoryBloc, HistoryState>(
        'emits HistoryLoaded with health tracking data',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => [
                    {
                      'date': '2026-06-01',
                      'symptoms': {'batuk': 2, 'demam': 1},
                      'additional_notes': '',
                    },
                  ]);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchRequested(
          year: 2026,
          month: 6,
        )),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<HistoryLoaded>());
          final loaded = state as HistoryLoaded;
          expect(loaded.healthTrackings, isNotEmpty);
        },
      );
    });

    group('HistoryFetchAllRequested', () {
      blocTest<HistoryBloc, HistoryState>(
        'emits [HistoryLoading, HistoryAllLoaded] when fetch all succeeds',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchAllRequested()),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryAllLoaded>(),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'emits [HistoryLoading, HistoryError] when fetch all fails',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenThrow(Exception('Network error'));
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchAllRequested()),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryError>(),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'emits HistoryAllLoaded with grouped sections',
        build: () {
          when(() => mockSchedule.fetchSchedules()).thenAnswer((_) async => [
                Medication(
                  id: 'med-1',
                  name: 'Paracetamol',
                  amount: '30',
                  type: 'Tablet',
                  dose: '500mg',
                  frequency: '1x sehari',
                  capsuleColor: 'Putih',
                  times: const [TimeOfDay(hour: 8, minute: 0)],
                  reminder: true,
                ),
              ]);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => [
                    {
                      'schedule_id': 'med-1',
                      'time_index': 0,
                      'date': '2026-06-01',
                    },
                  ]);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => [
                    {
                      'date': '2026-05-31',
                      'symptoms': {'batuk': 2},
                      'additional_notes': 'Sedikit batuk',
                    },
                  ]);
          return historyBloc;
        },
        act: (bloc) => bloc.add(HistoryFetchAllRequested()),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<HistoryAllLoaded>());
          final loaded = state as HistoryAllLoaded;
          expect(loaded.sections, isNotEmpty);
        },
      );
    });

    group('HistoryChangeMonth', () {
      blocTest<HistoryBloc, HistoryState>(
        'does nothing when state is not HistoryLoaded',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        seed: () => HistoryInitial(),
        act: (bloc) => bloc.add(HistoryChangeMonth(1)),
        expect: () => [],
      );

      blocTest<HistoryBloc, HistoryState>(
        'navigates to next month',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        seed: () => HistoryLoaded(
          calendarDays: const [],
          recentLogs: const [],
          displayYear: 2026,
          displayMonth: 6,
          monthLabel: 'Juni 2026',
          firstWeekday: 0,
          schedules: const [],
          doseCheckIns: const [],
          healthTrackings: const [],
        ),
        act: (bloc) => bloc.add(HistoryChangeMonth(1)),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryLoaded>(),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'navigates to previous month',
        build: () {
          when(() => mockSchedule.fetchSchedules())
              .thenAnswer((_) async => []);
          when(() => mockDoseCheckIn.getAllCheckIns())
              .thenAnswer((_) async => []);
          when(() => mockCheckIn.getAllHealthTracking())
              .thenAnswer((_) async => []);
          return historyBloc;
        },
        seed: () => HistoryLoaded(
          calendarDays: const [],
          recentLogs: const [],
          displayYear: 2026,
          displayMonth: 6,
          monthLabel: 'Juni 2026',
          firstWeekday: 0,
          schedules: const [],
          doseCheckIns: const [],
          healthTrackings: const [],
        ),
        act: (bloc) => bloc.add(HistoryChangeMonth(-1)),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryLoaded>(),
        ],
      );
    });
  });
}
