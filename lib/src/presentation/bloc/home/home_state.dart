part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  HomeLoaded({
    required this.userName,
    required this.treatmentDay,
    required this.totalDays,
    required this.progressPercent,
    required this.nextDoseTime,
    required this.nextDoseName,
    required this.schedules,
  });

  final String userName;
  final int treatmentDay;
  final int totalDays;
  final double progressPercent;
  final String nextDoseTime;
  final String nextDoseName;
  final List<MedicationScheduleItem> schedules;
}

final class HomeCheckInSuccess extends HomeState {}

final class HomeError extends HomeState {
  HomeError(this.message);

  final String message;
}
