part of 'home_bloc.dart';

sealed class HomeEvent {}

/// Triggered on page load to fetch schedule data.
final class HomeFetchSchedulesRequested extends HomeEvent {}

/// Triggered when the user taps "Check-in Dose" button.
final class HomeCheckInDoseRequested extends HomeEvent {
  HomeCheckInDoseRequested({required this.scheduleId});

  final String scheduleId;
}
