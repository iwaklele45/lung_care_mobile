import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class ResendPasswordResetOtp {
  ResendPasswordResetOtp({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<PasswordResetRequestResult> call({required String requestId}) {
    return _repository.resendPasswordResetOtp(requestId: requestId);
  }
}
