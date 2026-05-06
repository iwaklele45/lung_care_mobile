import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class ObserveAuthState {
  ObserveAuthState({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Stream<User?> call() => _repository.authStateChanges();
}
