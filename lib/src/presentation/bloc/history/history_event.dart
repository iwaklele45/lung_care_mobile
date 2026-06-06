part of 'history_bloc.dart';

sealed class HistoryEvent {}

final class HistoryFetchRequested extends HistoryEvent {
  HistoryFetchRequested({required this.year, required this.month});
  final int year;
  final int month;
}

final class HistoryFetchAllRequested extends HistoryEvent {}

final class HistoryChangeMonth extends HistoryEvent {
  HistoryChangeMonth(this.offset);
  final int offset;
}
