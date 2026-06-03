import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class CheckUserProfile {
  CheckUserProfile({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<bool> call({required String uid}) {
    return _repository.checkUserProfileExists(uid);
  }
}
