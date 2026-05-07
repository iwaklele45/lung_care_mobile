import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class CreateUserWithEmail {
  CreateUserWithEmail({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<UserCredential> call({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
  }) {
    return _repository.createUserWithEmailAndPassword(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      address: address,
    );
  }
}
