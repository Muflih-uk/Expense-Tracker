import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/paged_result.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<PagedResult<Transaction>>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  });

  Future<Result<PagedResult<Transaction>>> getExpenses({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  });

  Future<Result<PagedResult<Transaction>>> getIncome({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  });

  Future<Result<PagedResult<Transaction>>> getByCategory(
    int categoryId, {
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  });

  Future<Result<PagedResult<Transaction>>> getByAccount(
    int accountId, {
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  });

  Future<Result<PagedResult<Transaction>>> getDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? transactionType,
    int? category,
    int? account,
    int page = 1,
    String ordering = '-created_at',
  });

  Future<Result<TxSummaryResponse>> getSummary({String period = 'month'});

  Future<Result<Transaction>> getTransaction(int id);

  Future<Result<Transaction>> createTransaction(TransactionPayload payload);

  Future<Result<Transaction>> updateTransaction(
    int id,
    TransactionPayload payload,
  );

  Future<Result<void>> deleteTransaction(int id);
}