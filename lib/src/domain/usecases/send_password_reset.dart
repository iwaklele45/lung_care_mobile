import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class SendPasswordReset {
  SendPasswordReset({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
