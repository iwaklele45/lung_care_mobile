import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/src/data/datasource/check_in_remote_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/dose_check_in_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';

part 'history_event.dart';
part 'history_state.dart';

enum CalendarDayStatus { taken, missed, pending, future }

class CalendarDayData {
  const CalendarDayData({required this.day, required this.status});
  final int day;
  final CalendarDayStatus status;
}

class HistoryLogEntry {
  const HistoryLogEntry({
    required this.date,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.taken,
    required this.isHealthCheckIn,
  });
  final String date;
  final String time;
  final String title;
  final String subtitle;
  final bool taken;
  final bool isHealthCheckIn;
}

class MonthHistorySection {
  const MonthHistorySection({required this.label, required this.entries});
  final String label;
  final List<HistoryLogEntry> entries;
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    DoseCheckInDataSource? doseCheckInDataSource,
    CheckInRemoteDataSource? checkInDataSource,
    ScheduleRemoteDataSource? scheduleDataSource,
  })  : _doseCheckInDataSource =
            doseCheckInDataSource ?? DoseCheckInDataSource(),
        _checkInDataSource = checkInDataSource ?? CheckInRemoteDataSource(),
        _scheduleDataSource = scheduleDataSource ?? ScheduleRemoteDataSource(),
        super(HistoryInitial()) {
    on<HistoryFetchRequested>(_onFetch);
    on<HistoryFetchAllRequested>(_onFetchAll);
    on<HistoryChangeMonth>(_onChangeMonth);
  }

  final DoseCheckInDataSource _doseCheckInDataSource;
  final CheckInRemoteDataSource _checkInDataSource;
  final ScheduleRemoteDataSource _scheduleDataSource;

  List<Medication> _schedules = [];
  List<Map<String, dynamic>> _doseCheckIns = [];
  List<Map<String, dynamic>> _healthTrackings = [];
  bool _dataLoaded = false;

  static const _monthsId = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _monthsEn = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _dateEn(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} ${_monthsEn[dt.month]} ${dt.year}';

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final ampm = h >= 12 ? 'PM' : 'AM';
    final dh = h == 0 ? 12 : h > 12 ? h - 12 : h;
    return '$dh:${m.toString().padLeft(2, '0')} $ampm';
  }

  Future<void> _loadData() async {
    if (_dataLoaded) return;
    final results = await Future.wait([
      _scheduleDataSource.fetchSchedules(),
      _doseCheckInDataSource.getAllCheckIns(),
      _checkInDataSource.getAllHealthTracking(),
    ]);
    _schedules = results[0] as List<Medication>;
    _doseCheckIns = results[1] as List<Map<String, dynamic>>;
    _healthTrackings = results[2] as List<Map<String, dynamic>>;
    _dataLoaded = true;
  }

  Future<void> _onFetch(
    HistoryFetchRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      await _loadData();
      final year = event.year;
      final month = event.month;
      final today = DateTime.now();
      final todayDate =
          DateTime(today.year, today.month, today.day);

      final daysInMonth = DateTime(year, month + 1, 0).day;
      final firstWeekday = DateTime(year, month, 1).weekday % 7;

      final checkedInDates =
          _doseCheckIns.map((d) => d['date'] as String).toSet();

      final calendarDays = List.generate(daysInMonth, (i) {
        final day = i + 1;
        final date = DateTime(year, month, day);
        final dateStr =
            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        CalendarDayStatus status;
        if (date.isAfter(todayDate)) {
          status = CalendarDayStatus.future;
        } else if (checkedInDates.contains(dateStr)) {
          status = CalendarDayStatus.taken;
        } else if (date == todayDate) {
          status = CalendarDayStatus.pending;
        } else {
          status = CalendarDayStatus.missed;
        }
        return CalendarDayData(day: day, status: status);
      });

      final recentLogs = _buildRecentLogs(limit: 4);

      emit(HistoryLoaded(
        calendarDays: calendarDays,
        recentLogs: recentLogs,
        displayYear: year,
        displayMonth: month,
        monthLabel: '${_monthsId[month]} $year',
        firstWeekday: firstWeekday,
        schedules: _schedules,
        doseCheckIns: _doseCheckIns,
        healthTrackings: _healthTrackings,
      ));
    } catch (e) {
      emit(HistoryError('Gagal memuat riwayat. Silakan coba lagi.'));
    }
  }

  Future<void> _onFetchAll(
    HistoryFetchAllRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      await _loadData();
      final allEntries = _buildAllEntries();
      final sections = _groupByMonth(allEntries);

      emit(HistoryAllLoaded(sections: sections));
    } catch (e) {
      emit(HistoryError('Gagal memuat riwayat. Silakan coba lagi.'));
    }
  }

  void _onChangeMonth(
    HistoryChangeMonth event,
    Emitter<HistoryState> emit,
  ) {
    final s = state;
    if (s is! HistoryLoaded) return;
    final newDate = DateTime(s.displayYear, s.displayMonth + event.offset);
    add(HistoryFetchRequested(year: newDate.year, month: newDate.month));
  }

  List<HistoryLogEntry> _buildRecentLogs({int limit = 4}) {
    final entries = _buildAllEntries();
    return entries.take(limit).toList();
  }

  List<HistoryLogEntry> _buildAllEntries() {
    final scheduleMap = {for (final s in _schedules) s.id ?? '': s};

    final doseEntries = _doseCheckIns.map((d) {
      final scheduleId = d['schedule_id'] as String? ?? '';
      final schedule = scheduleMap[scheduleId];
      final timeIdx = d['time_index'] as int? ?? 0;
      final minutes = schedule != null &&
              timeIdx < schedule.times.length
          ? schedule.times[timeIdx].hour * 60 + schedule.times[timeIdx].minute
          : null;
      final timeStr = minutes != null ? _formatTime(minutes) : '--:--';
      final dateStr = d['date'] as String? ?? '';
      final parsedDate = _parseDate(dateStr);

      return HistoryLogEntry(
        date: _dateEn(parsedDate ?? DateTime.now()),
        time: timeStr,
        title: schedule?.name ?? 'Obat tidak dikenal',
        subtitle: schedule?.dose ?? '',
        taken: true,
        isHealthCheckIn: false,
      );
    }).toList();

    final healthEntries = _healthTrackings.map((h) {
      final dateStr = h['date'] as String? ?? '';
      final parsedDate = _parseDate(dateStr);
      final symptoms = (h['symptoms'] as Map?) ?? const {};
      final notes = (h['additional_notes'] as String?) ?? '';
      final summary = notes.isNotEmpty
          ? (notes.length > 40 ? '${notes.substring(0, 40)}...' : notes)
          : _symptomSummary(symptoms);

      return HistoryLogEntry(
        date: _dateEn(parsedDate ?? DateTime.now()),
        time: '',
        title: 'Daily Check-in',
        subtitle: summary,
        taken: true,
        isHealthCheckIn: true,
      );
    }).toList();

    final all = [...doseEntries, ...healthEntries];
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  List<MonthHistorySection> _groupByMonth(List<HistoryLogEntry> entries) {
    final grouped = <String, List<HistoryLogEntry>>{};
    for (final e in entries) {
      final parts = e.date.split(' ');
      if (parts.length < 3) continue;
      final monthYear = '${parts[1]} ${parts[2]}';
      grouped.putIfAbsent(monthYear, () => []).add(e);
    }
    return grouped.entries.map((e) {
      final mEn = e.key.split(' ')[0];
      final y = e.key.split(' ')[1];
      final idx = _monthsEn.indexOf(mEn);
      final label = idx > 0 ? '${_monthsId[idx].toUpperCase()} $y' : e.key.toUpperCase();
      return MonthHistorySection(label: label, entries: e.value);
    }).toList();
  }

  DateTime? _parseDate(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  String _symptomSummary(Map symptoms) {
    final nonZero = symptoms.entries
        .where((e) => (e.value is int) && (e.value as int) > 0)
        .map((e) => '${e.key}: ${e.value}')
        .take(3)
        .toList();
    return nonZero.isEmpty ? 'Tidak ada gejala' : nonZero.join(', ');
  }
}
