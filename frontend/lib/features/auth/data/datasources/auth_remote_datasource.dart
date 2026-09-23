import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.signup,
        data: {'name': name, 'email': email, 'password': password},
      );
      return _parseSession(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.signin,
        data: {'email': email, 'password': password},
      );
      return _parseSession(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<String> obtainToken({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.token,
        data: {'username': email, 'password': password},
      );
      return (response.data as Map<String, dynamic>)['token'] as String;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  AuthSession _parseSession(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final token = map['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ServerException('No token returned');
    }
    final userMap = Map<String, dynamic>.from(map['user'] as Map);
    final user = User(
      id: userMap['id'] as int,
      name: userMap['name'] as String? ?? '',
      email: userMap['email'] as String? ?? '',
    );
    return AuthSession(token: token, user: user);
  }
}