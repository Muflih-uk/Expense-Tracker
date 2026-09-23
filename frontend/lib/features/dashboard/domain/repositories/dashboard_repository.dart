import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard.dart';

abstract class DashboardRepository {
  Future<Result<DashboardData>> getDashboard({String period = 'month'});

  Future<Result<QuickStats>> getQuickStats();
}