part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class CheckAuthStatusEvent extends AuthEvent {}

final class AuthUserChanged extends AuthEvent {
  AuthUserChanged(this.user);

  final User? user;
}

final class AuthSignInRequested extends AuthEvent {
  AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;
}

final class AuthSignUpRequested extends AuthEvent {
  AuthSignUpRequested({required this.email, required this.password});

  final String email;
  final String password;
}

final class AuthPasswordResetRequested extends AuthEvent {
  AuthPasswordResetRequested({required this.email});

  final String email;
}

final class AuthSignOutRequested extends AuthEvent {}
