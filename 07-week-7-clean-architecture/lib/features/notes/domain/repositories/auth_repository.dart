import '../../../../core/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<({User? user, Failure? failure})> login(String email, String password);
}