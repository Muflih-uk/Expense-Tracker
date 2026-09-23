import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/repository_guard.dart';
import 'package:expense_tracker/features/users/data/datasources/user_remote_datasource.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<User>> getCurrentUser() {
    return guardFuture(() => _remoteDataSource.getCurrentUser());
  }

  @override
  Future<Result<User>> updateProfile({
    required int id,
    String? name,
    String? email,
    String? password,
  }) {
    return guardFuture(
      () => _remoteDataSource.updateUser(
        id,
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Result<void>> deleteAccount(int id) {
    return guardFuture(() => _remoteDataSource.deleteUser(id));
  }

  @override
  Future<Result<String>> getVersion() {
    return guardFuture(() => _remoteDataSource.getVersion());
  }
}