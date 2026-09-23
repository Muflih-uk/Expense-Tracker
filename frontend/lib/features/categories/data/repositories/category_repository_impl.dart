import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/repository_guard.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remoteDataSource);

  final CategoryRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Category>>> getCategories() {
    return guardFuture(() => _remoteDataSource.getCategories());
  }

  @override
  Future<Result<List<CategoryWithStats>>> getCategoriesWithStats({
    String period = 'month',
  }) {
    return guardFuture(
      () => _remoteDataSource.getCategoriesWithStats(period: period),
    );
  }

  @override
  Future<Result<Category>> createCategory({required String title}) {
    return guardFuture(() => _remoteDataSource.createCategory(title: title));
  }

  @override
  Future<Result<void>> deleteCategory(int id) {
    return guardFuture(() => _remoteDataSource.deleteCategory(id));
  }

  @override
  Future<Result<List<Transaction>>> getCategoryTransactions(int id) {
    return guardFuture(
      () => _remoteDataSource.getCategoryTransactions(id),
    );
  }
}