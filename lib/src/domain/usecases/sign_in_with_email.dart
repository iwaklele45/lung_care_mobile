import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class SignInWithEmail {
  SignInWithEmail({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<UserCredential> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
