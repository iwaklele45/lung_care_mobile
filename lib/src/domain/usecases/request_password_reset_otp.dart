import 'package:lung_care_mobile/src/domain/entities/password_reset_result.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class RequestPasswordResetOtp {
  RequestPasswordResetOtp({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<PasswordResetRequestResult> call({required String identifier}) {
    return _repository.requestPasswordResetOtp(identifier: identifier);
  }
}
