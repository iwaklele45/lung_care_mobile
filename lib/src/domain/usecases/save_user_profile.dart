import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class SaveUserProfile {
  SaveUserProfile({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<void> call({
    required String uid,
    required String name,
    required String phoneNumber,
    required String address,
    required String email,
    String? profilePicturePath,
  }) {
    return _repository.saveUserProfile(
      uid: uid,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      email: email,
      profilePicturePath: profilePicturePath,
    );
  }
}
