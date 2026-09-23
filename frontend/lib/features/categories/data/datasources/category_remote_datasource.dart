import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.categories);
      final data = Map<String, dynamic>.from(response.data as Map);
      final results = (data['results'] as List<dynamic>? ?? [])
          .map(
            (item) => CategoryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList();
      var all = List<Category>.from(results);
      var next = data['next'] as String?;
      while (next != null && next.isNotEmpty) {
        final pageResponse = await _client.dio.get(next);
        final pageData = Map<String, dynamic>.from(pageResponse.data as Map);
        all.addAll(
          (pageData['results'] as List<dynamic>? ?? [])
              .map(
                (item) => CategoryModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ).toEntity(),
              )
              .toList(),
        );
        next = pageData['next'] as String?;
      }
      return all;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Category> createCategory({required String title}) async {
    try {
      final response = await _client.dio
          .post(ApiEndpoints.categories, data: {'title': title});
      return CategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Category> getCategory(int id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.categoryById(id));
      return CategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Category> updateCategory(int id, {required String title}) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.categoryById(id),
        data: {'title': title},
      );
      return CategoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _client.dio.delete(ApiEndpoints.categoryById(id));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<CategoryWithStats>> getCategoriesWithStats({
    String period = 'month',
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.categoriesWithStats,
        queryParameters: {'period': period},
      );
      return (response.data as List<dynamic>? ?? [])
          .map(
            (item) => CategoryWithStatsModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<Transaction>> getCategoryTransactions(int id) async {
    try {
      final response = await _client.dio
          .get(ApiEndpoints.categoryTransactions(id));
      return (response.data as List<dynamic>? ?? [])
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

class CategoryModel {
  const CategoryModel({required this.id, required this.title});

  final int id;
  final String title;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  Category toEntity() => Category(id: id, title: title);
}

class CategoryWithStatsModel {
  const CategoryWithStatsModel({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.transactionCount,
  });

  final int id;
  final String title;
  final double totalAmount;
  final int transactionCount;

  factory CategoryWithStatsModel.fromJson(Map<String, dynamic> json) {
    return CategoryWithStatsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      totalAmount: parseAmount(json['total_amount']),
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }

  CategoryWithStats toEntity() => CategoryWithStats(
        id: id,
        title: title,
        totalAmount: totalAmount,
        transactionCount: transactionCount,
      );
}