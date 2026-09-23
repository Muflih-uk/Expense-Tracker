import 'package:dio/dio.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

AppException mapDioException(DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.badCertificate:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.cancel:
      return const ServerException('Request cancelled');
    case DioExceptionType.badResponse:
      return _mapBadResponse(status, data);
    case DioExceptionType.unknown:
      final text = '${error.error ?? error.message ?? ''}';
      if (text.contains('SocketException') || text.contains('Handshake')) {
        return const NetworkException();
      }
      return ServerException(error.message ?? 'Something went wrong');
  }
}

AppException _mapBadResponse(int? status, dynamic data) {
  final map = data is Map<String, dynamic> ? data : null;
  final message = map?['error']?.toString() ??
      map?['detail']?.toString() ??
      map?['message']?.toString();

  switch (status) {
    case 400:
      final fieldErrors = _fieldErrors(map);
      if (fieldErrors.isEmpty) {
        return ValidationException(
          message ?? 'Invalid request',
          fieldErrors: const {},
          statusCode: 400,
        );
      }
      return ValidationException(
        message ?? 'Check the highlighted fields',
        fieldErrors: fieldErrors,
        statusCode: 400,
      );
    case 401:
      return AuthException(message ?? 'Invalid credentials', 401);
    case 403:
      return ForbiddenException(message ?? 'Access denied', 403);
    case 404:
      return NotFoundException(message ?? 'Not found', 404);
    default:
      return ServerException(message ?? 'Something went wrong', status);
  }
}

Map<String, List<String>> _fieldErrors(Map<String, dynamic>? data) {
  if (data == null) return const {};
  final errors = <String, List<String>>{};
  data.forEach((key, value) {
    if (value is List) {
      errors[key] = value.map((e) => e.toString()).toList();
    } else if (value is String &&
        key != 'error' &&
        key != 'detail' &&
        key != 'message' &&
        key != 'non_field_errors') {
      errors[key] = [value];
    }
  });
  return errors;
}
