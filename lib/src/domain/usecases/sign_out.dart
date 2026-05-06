import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class SignOut {
  SignOut({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
