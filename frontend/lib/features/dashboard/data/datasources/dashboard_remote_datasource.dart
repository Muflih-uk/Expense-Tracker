import 'package:dio/dio.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/network/error_mapper.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final DioClient _client;

  Future<DashboardData> getDashboard({String period = 'month'}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.dashboard,
        queryParameters: {'period': period},
      );
      return _parseDashboard(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<QuickStats> getQuickStats() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.dashboardQuickStats);
      final map = Map<String, dynamic>.from(response.data as Map);
      return QuickStats(
        today: _stat(map['today']),
        week: _stat(map['week']),
        month: _stat(map['month']),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  DashboardData _parseDashboard(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final period = map['period'] is Map
        ? Map<String, dynamic>.from((map['period'] as Map).cast<String, dynamic>())
        : <String, dynamic>{};
    final summary = map['summary'] is Map
        ? Map<String, dynamic>.from((map['summary'] as Map).cast<String, dynamic>())
        : <String, dynamic>{};
    return DashboardData(
      period: DashboardPeriod(
        type: period['type'] as String? ?? 'month',
        startDate: period['start_date'] as String? ?? '',
        endDate: period['end_date'] as String? ?? '',
      ),
      summary: DashboardSummary(
        totalIncome: parseAmount(summary['total_income']),
        totalExpenses: parseAmount(summary['total_expenses']),
        netAmount: parseAmount(summary['net_amount']),
        transactionCount: summary['transaction_count'] as int? ?? 0,
        totalAccountBalance: parseAmount(summary['total_account_balance']),
      ),
      categoryBreakdown: _breakdown(map['category_breakdown']),
      accountSummary: (map['account_summary'] as List<dynamic>? ?? [])
          .map((item) {
            final m = Map<String, dynamic>.from(item as Map);
            return AccountSummaryItem(
              id: m['id'] as int? ?? 0,
              title: m['title'] as String? ?? '',
              initialBalance: parseAmount(m['initial_balance']),
              currentBalance: parseAmount(m['current_balance']),
              change: parseAmount(m['change']),
            );
          })
          .toList(),
      recentTransactions: (map['recent_transactions'] as List<dynamic>? ?? [])
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ).toEntity(),
          )
          .toList(),
      monthlyTrend: (map['monthly_trend'] as List<dynamic>? ?? [])
          .map((item) {
            final m = Map<String, dynamic>.from(item as Map);
            return MonthlyTrend(
              month: m['month'] as String? ?? '',
              income: parseAmount(m['income']),
              expenses: parseAmount(m['expenses']),
              net: parseAmount(m['net']),
            );
          })
          .toList(),
      topCategories: _breakdown(map['top_categories']),
    );
  }

  List<CategoryBreakdown> _breakdown(dynamic raw) {
    return (raw as List<dynamic>? ?? [])
        .map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          return CategoryBreakdown(
            title: m['category__title'] as String? ?? '',
            total: parseAmount(m['total']),
            count: m['count'] as int? ?? 0,
          );
        })
        .toList();
  }

  QuickStat _stat(dynamic raw) {
    if (raw == null) return const QuickStat(income: 0, expenses: 0, net: 0, count: 0);
    final map = Map<String, dynamic>.from(raw as Map);
    return QuickStat(
      income: parseAmount(map['income']),
      expenses: parseAmount(map['expenses']),
      net: parseAmount(map['net']),
      count: map['count'] as int? ?? 0,
    );
  }
}