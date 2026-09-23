import 'package:dio/dio.dart';
import 'package:expense_tracker/core/storage/local_storage.dart';

class DioClient {
  DioClient({required LocalStorage localStorage}) : _localStorage = localStorage {
    dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.dev.projectscranton.com',
        ),
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _localStorage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Token $token';
          }
          // Some deployments/CDNs require Referer/Origin for CSRF checks
          // on non-browser clients; set safely from baseUrl
          try {
            final base = options.baseUrl;
            if (base.isNotEmpty) {
              final uri = Uri.parse(base.endsWith('/') ? base : '$base/');
              options.headers['Origin'] = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
              options.headers['Referer'] = uri.toString();
            }
          } catch (_) {}
          handler.next(options);
        },
        onError: (error, handler) {
          final hadToken =
              error.requestOptions.headers['Authorization'] != null;
          if (error.response?.statusCode == 401 && hadToken) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final LocalStorage _localStorage;
  void Function()? onUnauthorized;
  late final Dio dio;
}
