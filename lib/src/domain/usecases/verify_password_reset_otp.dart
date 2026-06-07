import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class VerifyPasswordResetOtp {
  VerifyPasswordResetOtp({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<PasswordResetVerificationResult> call({
    required String requestId,
    required String code,
  }) {
    return _repository.verifyPasswordResetOtp(requestId: requestId, code: code);
  }
}
