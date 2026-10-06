// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../../../core/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<({User? user, Failure? failure})> login(String email, String password) async {
    try {
      // Simulasi request API / Dio
      if (email == 'admin@polinema.ac.id' && password == '123456') {
        final model = UserModel.fromJson({
          'id': 'usr_1',
          'email': email,
          'token': 'secret_jwt_token',
        });
        return (user: model.toEntity(), failure: null);
      }
      return (user: null, failure: const NetworkFailure('Email atau password salah'));
    } catch (e) {
      return (user: null, failure: NetworkFailure('Gagal terhubung ke server: $e'));
    }
  }
}