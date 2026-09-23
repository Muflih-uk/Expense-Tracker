import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/paged_result.dart';
import 'package:expense_tracker/core/network/repository_guard.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._remoteDataSource);

  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PagedResult<Transaction>>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) {
    return guardFuture(
      () => _remoteDataSource.getTransactions(filter: filter, page: page),
    );
  }

  @override
  Future<Result<PagedResult<Transaction>>> getExpenses({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) {
    return guardFuture(
      () => _remoteDataSource.getExpenses(filter: filter, page: page),
    );
  }

  @override
  Future<Result<PagedResult<Transaction>>> getIncome({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) {
    return guardFuture(
      () => _remoteDataSource.getIncome(filter: filter, page: page),
    );
  }

  @override
  Future<Result<PagedResult<Transaction>>> getByCategory(
    int categoryId, {
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) {
    return guardFuture(
      () => _remoteDataSource.getByCategory(
        categoryId,
        filter: filter,
        page: page,
      ),
    );
  }

  @override
  Future<Result<PagedResult<Transaction>>> getByAccount(
    int accountId, {
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) {
    return guardFuture(
      () => _remoteDataSource.getByAccount(
        accountId,
        filter: filter,
        page: page,
      ),
    );
  }

  @override
  Future<Result<PagedResult<Transaction>>> getDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? transactionType,
    int? category,
    int? account,
    int page = 1,
    String ordering = '-created_at',
  }) {
    return guardFuture(
      () => _remoteDataSource.getDateRange(
        startDate: startDate,
        endDate: endDate,
        transactionType: transactionType,
        category: category,
        account: account,
        page: page,
        ordering: ordering,
      ),
    );
  }

  @override
  Future<Result<TxSummaryResponse>> getSummary({String period = 'month'}) {
    return guardFuture(() => _remoteDataSource.getSummary(period: period));
  }

  @override
  Future<Result<Transaction>> getTransaction(int id) {
    return guardFuture(() => _remoteDataSource.getTransaction(id));
  }

  @override
  Future<Result<Transaction>> createTransaction(TransactionPayload payload) {
    return guardFuture(
      () => _remoteDataSource.createTransaction(payload),
    );
  }

  @override
  Future<Result<Transaction>> updateTransaction(
    int id,
    TransactionPayload payload,
  ) {
    return guardFuture(
      () => _remoteDataSource.updateTransaction(id, payload),
    );
  }

  @override
  Future<Result<void>> deleteTransaction(int id) {
    return guardFuture(() => _remoteDataSource.deleteTransaction(id));
  }
}