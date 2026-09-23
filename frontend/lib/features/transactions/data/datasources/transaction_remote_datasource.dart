import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';
import 'package:expense_tracker/core/network/paged_result.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._client);

  final DioClient _client;

  Future<PagedResult<Transaction>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.transactions,
        queryParameters: _buildQuery(filter, page),
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => TransactionModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PagedResult<Transaction>> getExpenses({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.transactionsExpenses,
        queryParameters: _buildQuery(filter, page),
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => TransactionModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PagedResult<Transaction>> getIncome({
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.transactionsIncome,
        queryParameters: _buildQuery(filter, page),
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => TransactionModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PagedResult<Transaction>> getByCategory(
    int categoryId, {
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) async {
    try {
      final query = _buildQuery(filter, page)..['category'] = categoryId;
      final response = await _client.dio.get(
        ApiEndpoints.transactionsByCategory,
        queryParameters: query,
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => TransactionModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PagedResult<Transaction>> getByAccount(
    int accountId, {
    TransactionFilter filter = const TransactionFilter(),
    int page = 1,
  }) async {
    try {
      final query = _buildQuery(filter, page)..['account'] = accountId;
      final response = await _client.dio.get(
        ApiEndpoints.transactionsByAccount,
        queryParameters: query,
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => TransactionModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PagedResult<Transaction>> getDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? transactionType,
    int? category,
    int? account,
    int page = 1,
    String ordering = '-created_at',
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.transactionsDateRange,
        queryParameters: {
          'start_date': toApiDate(startDate),
          'end_date': toApiDate(endDate),
          'page': page,
          'ordering': ordering,
          if (transactionType != null) 'transaction_type': transactionType,
          if (category != null) 'category': category,
          if (account != null) 'account': account,
        },
      );
      return PagedResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (item) => TransactionModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<TxSummaryResponse> getSummary({String period = 'month'}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.transactionsSummary,
        queryParameters: {'period': period},
      );
      return _parseSummary(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Transaction> createTransaction(TransactionPayload payload) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.transactions,
        data: await _payload(payload),
      );
      return TransactionModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Transaction> updateTransaction(
    int id,
    TransactionPayload payload,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiEndpoints.transactionById(id),
        data: await _payload(payload),
      );
      return TransactionModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Transaction> getTransaction(int id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.transactionById(id));
      return TransactionModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _client.dio.delete(ApiEndpoints.transactionById(id));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Map<String, dynamic> _buildQuery(
    TransactionFilter filter,
    int page,
  ) {
    return {
      'page': page,
      'ordering': filter.ordering,
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.period.isNotEmpty && filter.period != 'all')
        'period': filter.period,
      if (filter.categoryId != null) 'category': filter.categoryId,
      if (filter.accountId != null) 'account': filter.accountId,
      if (filter.amountMin != null) 'amount_min': filter.amountMin,
      if (filter.amountMax != null) 'amount_max': filter.amountMax,
      if (filter.dateFrom != null) 'date_from': toApiDate(filter.dateFrom!),
      if (filter.dateTo != null) 'date_to': toApiDate(filter.dateTo!),
    };
  }

  Future<Object> _payload(TransactionPayload payload) async {
    final fields = <String, dynamic>{
      'title': payload.title,
      'amount': payload.amount.toStringAsFixed(2),
      'transaction_type': payload.transactionType,
      if (payload.categoryId != null) 'category': payload.categoryId,
      if (payload.accountId != null) 'account': payload.accountId,
      'date': toApiDate(payload.date),
      if (payload.notes != null && payload.notes!.isNotEmpty)
        'notes': payload.notes,
      if (payload.tags != null && payload.tags!.isNotEmpty) 'tags': payload.tags,
    };

    final receiptPath = payload.receiptPath;
    if (receiptPath == null) return fields;

    final form = FormData.fromMap({
      ...fields,
      'receipt': await MultipartFile.fromFile(receiptPath),
    });
    return form;
  }

  TxSummaryResponse _parseSummary(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final summary = map['summary'] is Map
        ? Map<String, dynamic>.from(
            (map['summary'] as Map).cast<String, dynamic>(),
          )
        : <String, dynamic>{};
    return TxSummaryResponse(
      totalIncome: parseAmount(summary['total_income']),
      totalExpenses: parseAmount(summary['total_expenses']),
      netAmount: parseAmount(summary['net_amount']),
      transactionCount: summary['transaction_count'] as int? ?? 0,
      recentTransactions: (map['recent_transactions'] as List<dynamic>? ?? [])
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList(),
    );
  }
}