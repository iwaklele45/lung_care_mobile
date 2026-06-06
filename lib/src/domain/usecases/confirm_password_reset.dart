import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class ConfirmPasswordReset {
  ConfirmPasswordReset({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<void> call({required String resetToken, required String newPassword}) {
    return _repository.confirmPasswordReset(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }
}
