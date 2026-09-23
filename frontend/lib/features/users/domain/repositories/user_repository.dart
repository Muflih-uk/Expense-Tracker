import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';

abstract class UserRepository {
  Future<Result<User>> getCurrentUser();

  Future<Result<User>> updateProfile({
    required int id,
    String? name,
    String? email,
    String? password,
  });

  Future<Result<void>> deleteAccount(int id);

  Future<Result<String>> getVersion();
}