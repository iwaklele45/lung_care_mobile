import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/features/auth/domain/repositories/auth_repository.dart';

class CreateUserWithEmail {
  CreateUserWithEmail({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<UserCredential> call({
    required String email,
    required String password,
  }) {
    return _repository.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
