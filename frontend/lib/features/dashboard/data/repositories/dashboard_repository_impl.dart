import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/repository_guard.dart';
import 'package:expense_tracker/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DashboardData>> getDashboard({String period = 'month'}) {
    return guardFuture(() => _remoteDataSource.getDashboard(period: period));
  }

  @override
  Future<Result<QuickStats>> getQuickStats() {
    return guardFuture(() => _remoteDataSource.getQuickStats());
  }
}