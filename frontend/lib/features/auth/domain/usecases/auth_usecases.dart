import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';

abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

class NoParams {
  const NoParams();
}

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignUpParams {
  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

class SignIn extends UseCase<AuthSession, SignInParams> {
  SignIn(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(SignInParams params) {
    return _repository.signIn(email: params.email, password: params.password);
  }
}

class SignUp extends UseCase<AuthSession, SignUpParams> {
  SignUp(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(SignUpParams params) {
    return _repository.signUp(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class SignOut extends UseCase<void, NoParams> {
  SignOut(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.signOut();
}

class RestoreSession extends UseCase<AuthSession?, NoParams> {
  RestoreSession(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<AuthSession?>> call(NoParams params) =>
      _repository.restoreSession();
}