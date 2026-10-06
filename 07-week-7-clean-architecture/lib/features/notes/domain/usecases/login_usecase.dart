import '../../../../core/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<({User? user, Failure? failure})> call(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return Future.value((
        user: null,
        failure: const LocalFailure('Email dan password wajib diisi'),
      ));
    }
    return _repository.login(email, password);
  }
}