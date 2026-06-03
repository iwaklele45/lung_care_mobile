import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  SignInWithGoogle({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<UserCredential> call() {
    return _repository.signInWithGoogle();
  }
}
