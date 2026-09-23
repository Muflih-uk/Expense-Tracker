sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid credentials']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Access denied']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Storage error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(
    this.fieldErrors, [
    super.message = 'Check the highlighted fields',
  ]);
  final Map<String, List<String>> fieldErrors;

  String? fieldError(String field) {
    final errors = fieldErrors[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }
}
