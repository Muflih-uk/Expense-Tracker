import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';
import 'package:expense_tracker/core/network/paged_result.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class AccountRemoteDataSource {
  AccountRemoteDataSource(this._client);

  final DioClient _client;

  Future<PagedResult<Account>> getAccounts({int page = 1}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.accounts,
        queryParameters: {'page': page},
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => AccountModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Account> createAccount({
    required String title,
    double initial = 0,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.accounts,
        data: {'title': title, 'initial': initial.toStringAsFixed(2)},
      );
      return AccountModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Account> getAccount(int id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.accountById(id));
      return AccountModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Account> updateAccount(
    int id, {
    String? title,
    double? initial,
  }) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.accountById(id),
        data: {
          if (title != null) 'title': title,
          if (initial != null) 'initial': initial.toStringAsFixed(2),
        },
      );
      return AccountModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _client.dio.delete(ApiEndpoints.accountById(id));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<Account>> getAccountsWithBalance() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.accountsWithBalance);
      return (response.data as List<dynamic>? ?? [])
          .map(
            (item) => AccountModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<AccountSummary> getAccountSummary() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.accountsSummary);
      return AccountSummaryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<Transaction>> getAccountTransactions(int id) async {
    try {
      final response = await _client.dio
          .get(ApiEndpoints.accountTransactions(id));
      return (response.data as List<dynamic>? ?? [])
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<BalanceHistory> getBalanceHistory(
    int id, {
    String period = 'month',
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.accountBalanceHistory(id),
        queryParameters: {'period': period},
      );
      return BalanceHistoryModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

class AccountModel {
  const AccountModel({
    required this.id,
    required this.title,
    required this.initial,
    required this.currentBalance,
    this.user,
  });

  final int id;
  final String title;
  final double initial;
  final double currentBalance;
  final int? user;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      initial: parseAmount(json['initial']),
      currentBalance: parseAmount(json['current_balance']),
      user: json['user'] as int?,
    );
  }

  Account toEntity() => Account(
        id: id,
        title: title,
        initial: initial,
        currentBalance: currentBalance,
        user: user,
      );
}

class AccountSummaryModel {
  const AccountSummaryModel({
    required this.totalAccounts,
    required this.totalInitialBalance,
    required this.totalCurrentBalance,
    required this.totalChange,
    required this.accounts,
  });

  final int totalAccounts;
  final double totalInitialBalance;
  final double totalCurrentBalance;
  final double totalChange;
  final List<Account> accounts;

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      totalAccounts: json['total_accounts'] as int? ?? 0,
      totalInitialBalance: parseAmount(json['total_initial_balance']),
      totalCurrentBalance: parseAmount(json['total_current_balance']),
      totalChange: parseAmount(json['total_change']),
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .map(
            (item) => AccountModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList(),
    );
  }

  AccountSummary toEntity() => AccountSummary(
        totalAccounts: totalAccounts,
        totalInitialBalance: totalInitialBalance,
        totalCurrentBalance: totalCurrentBalance,
        totalChange: totalChange,
        accounts: accounts,
      );
}

class BalanceHistoryModel {
  const BalanceHistoryModel({
    required this.initialBalance,
    required this.currentBalance,
    required this.entries,
  });

  final double initialBalance;
  final double currentBalance;
  final List<BalanceHistoryEntry> entries;

  factory BalanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return BalanceHistoryModel(
      initialBalance: parseAmount(json['initial_balance']),
      currentBalance: parseAmount(json['current_balance']),
      entries: (json['balance_history'] as List<dynamic>? ?? [])
          .map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final transaction = map['transaction'] is Map
                ? Map<String, dynamic>.from(
                    (map['transaction'] as Map).cast<String, dynamic>(),
                  )
                : <String, dynamic>{};
            return BalanceHistoryEntry(
              date: map['date'] as String? ?? '',
              balance: parseAmount(map['balance']),
              title: transaction['title'] as String? ?? '',
              amount: parseAmount(transaction['amount']),
              type: transaction['type'] as String? ?? 'expense',
            );
          })
          .toList(),
    );
  }

  BalanceHistory toEntity() => BalanceHistory(
        initialBalance: initialBalance,
        currentBalance: currentBalance,
        entries: entries,
      );
}