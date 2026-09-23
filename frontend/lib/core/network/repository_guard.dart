import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';

Future<Result<T>> guardFuture<T>(Future<T> Function() run) async {
  try {
    return Success(await run());
  } on AppException catch (error) {
    return Err(error.toFailure());
  } catch (_) {
    return const Err(ServerFailure());
  }
}