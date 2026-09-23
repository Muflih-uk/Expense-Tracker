import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';

class BootDataSource {
  BootDataSource(this._client);

  final DioClient _client;

  Future<String> checkServer() async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.version,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
      final data = response.data;
      if (data is Map && data['version'] != null) {
        return '${data['version']}';
      }
      return '$data';
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}