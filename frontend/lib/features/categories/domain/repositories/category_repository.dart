import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> getCategories();

  Future<Result<List<CategoryWithStats>>> getCategoriesWithStats({
    String period = 'month',
  });

  Future<Result<Category>> createCategory({required String title});

  Future<Result<void>> deleteCategory(int id);

  Future<Result<List<Transaction>>> getCategoryTransactions(int id);
}