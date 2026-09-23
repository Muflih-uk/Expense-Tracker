import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AuthSession>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<AuthSession?>> restoreSession();
}