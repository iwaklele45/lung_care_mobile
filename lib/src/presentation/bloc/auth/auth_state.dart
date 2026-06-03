part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthAuthenticated extends AuthState {}

final class AuthUnauthenticated extends AuthState {}

final class AuthRegistrationSuccess extends AuthState {}

final class AuthError extends AuthState {
  AuthError(this.message);

  final String message;
}

final class AuthLoading extends AuthState {}

final class AuthProfileIncomplete extends AuthState {}

final class AuthProfileSaved extends AuthState {}

final class AuthLoggedOut extends AuthState {
  AuthLoggedOut({this.message = 'Berhasil logout.'});

  final String message;
}
