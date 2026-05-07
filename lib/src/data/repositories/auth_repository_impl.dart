import 'package:firebase_auth/firebase_auth.dart';
import 'package:lung_care_mobile/src/data/datasource/auth_remote_data_source.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<User?> authStateChanges() => _remoteDataSource.authStateChanges();

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
  }) {
    return _remoteDataSource.createUserWithEmailAndPassword(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      address: address,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _remoteDataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
