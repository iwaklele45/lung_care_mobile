part of 'history_bloc.dart';

sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  HistoryLoaded({
    required this.calendarDays,
    required this.recentLogs,
    required this.displayYear,
    required this.displayMonth,
    required this.monthLabel,
    required this.firstWeekday,
    required this.schedules,
    required this.doseCheckIns,
    required this.healthTrackings,
  });

  final List<CalendarDayData> calendarDays;
  final List<HistoryLogEntry> recentLogs;
  final int displayYear;
  final int displayMonth;
  final String monthLabel;
  final int firstWeekday;
  final List<Medication> schedules;
  final List<Map<String, dynamic>> doseCheckIns;
  final List<Map<String, dynamic>> healthTrackings;
}

final class HistoryAllLoaded extends HistoryState {
  HistoryAllLoaded({required this.sections});
  final List<MonthHistorySection> sections;
}

final class HistoryError extends HistoryState {
  HistoryError(this.message);
  final String message;
}
