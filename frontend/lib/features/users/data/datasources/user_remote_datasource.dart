import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';
import 'package:expense_tracker/core/network/paged_result.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._client);

  final DioClient _client;

  Future<PagedResult<User>> getUsers({int page = 1}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.users,
        queryParameters: {'page': page},
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => UserModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<User> getCurrentUser() async {
    final result = await getUsers();
    if (result.results.isEmpty) {
      throw const NotFoundException('Profile not found', 404);
    }
    return result.results.first;
  }

  Future<User> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.users,
        data: {'name': name, 'email': email, 'password': password},
      );
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<User> getUser(int id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.userById(id));
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<User> updateUser(
    int id, {
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.userById(id),
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
        },
      );
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _client.dio.delete(ApiEndpoints.userById(id));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<String> getVersion() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.version);
      final raw = response.data;
      if (raw is String) return raw;
      if (raw is Map && raw['version'] != null) {
        return raw['version'].toString();
      }
      return raw.toString();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  User toEntity() => User(id: id, name: name, email: email);
}

class StoredUser {
  static Map<String, dynamic> encode(User user) => {
        'id': user.id,
        'name': user.name,
        'email': user.email,
      };

  static User decode(String raw) {
    final decoded = jsonDecode(raw);
    final map = decoded is Map<String, dynamic>
        ? decoded
        : Map<String, dynamic>.from(decoded as Map);
    return UserModel.fromJson(map).toEntity();
  }
}