import 'package:expense_tracker/core/error/failure.dart';

class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  Failure toFailure() {
    return switch (this) {
      NetworkException() => const NetworkFailure(),
      AuthException() => AuthFailure(message),
      NotFoundException() => NotFoundFailure(message),
      ForbiddenException() => ForbiddenFailure(message),
      ValidationException() => ValidationFailure(
        fieldErrors ?? const {},
        message,
      ),
      CacheException() => CacheFailure(message),
      _ => ServerFailure(message),
    };
  }
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class AuthException extends AppException {
  const AuthException([
    super.message = 'Invalid credentials',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.fieldErrors,
    super.statusCode,
  });
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Not found',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'Access denied',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Something went wrong',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Storage error']);
}
