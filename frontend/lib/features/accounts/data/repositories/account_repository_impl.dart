import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/repository_guard.dart';
import 'package:expense_tracker/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._remoteDataSource);

  final AccountRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Account>>> getAccountsWithBalance() {
    return guardFuture(() => _remoteDataSource.getAccountsWithBalance());
  }

  @override
  Future<Result<AccountSummary>> getAccountSummary() {
    return guardFuture(() => _remoteDataSource.getAccountSummary());
  }

  @override
  Future<Result<Account>> getAccount(int id) {
    return guardFuture(() => _remoteDataSource.getAccount(id));
  }

  @override
  Future<Result<Account>> createAccount({
    required String title,
    double initial = 0,
  }) {
    return guardFuture(
      () => _remoteDataSource.createAccount(title: title, initial: initial),
    );
  }

  @override
  Future<Result<void>> deleteAccount(int id) {
    return guardFuture(() => _remoteDataSource.deleteAccount(id));
  }

  @override
  Future<Result<List<Transaction>>> getAccountTransactions(int id) {
    return guardFuture(
      () => _remoteDataSource.getAccountTransactions(id),
    );
  }

  @override
  Future<Result<BalanceHistory>> getBalanceHistory(
    int id, {
    String period = 'month',
  }) {
    return guardFuture(
      () => _remoteDataSource.getBalanceHistory(id, period: period),
    );
  }
}