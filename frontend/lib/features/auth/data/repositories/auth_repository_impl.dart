import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/repository_guard.dart';
import 'package:expense_tracker/core/storage/local_storage.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/users/data/datasources/user_remote_datasource.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localStorage = localStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    return guardFuture(() async {
      final session = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      await _localStorage.saveSession(
        token: session.token,
        user: StoredUser.encode(session.user),
      );
      return session;
    });
  }

  @override
  Future<Result<AuthSession>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return guardFuture(() async {
      final session = await _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
      await _localStorage.saveSession(
        token: session.token,
        user: StoredUser.encode(session.user),
      );
      return session;
    });
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (_) {
      // server unreachable during logout still clears the local session
    }
    await _localStorage.clearSession();
    return const Success(null);
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    final token = _localStorage.token;
    if (token == null || token.isEmpty) {
      return const Success(null);
    }
    try {
      final user = StoredUser.decode(_localStorage.userJson!);
      return Success(AuthSession(token: token, user: user));
    } on CacheException {
      await _localStorage.clearSession();
      return const Success(null);
    }
  }
}