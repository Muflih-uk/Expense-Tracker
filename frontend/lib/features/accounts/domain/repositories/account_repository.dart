import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

abstract class AccountRepository {
  Future<Result<List<Account>>> getAccountsWithBalance();

  Future<Result<AccountSummary>> getAccountSummary();

  Future<Result<Account>> getAccount(int id);

  Future<Result<Account>> createAccount({
    required String title,
    double initial = 0,
  });

  Future<Result<void>> deleteAccount(int id);

  Future<Result<List<Transaction>>> getAccountTransactions(int id);

  Future<Result<BalanceHistory>> getBalanceHistory(
    int id, {
    String period = 'month',
  });
}