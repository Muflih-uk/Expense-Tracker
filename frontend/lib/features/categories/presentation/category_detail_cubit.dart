import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryDetailState extends Equatable {
  const CategoryDetailState({
    this.isLoading = false,
    this.transactions = const [],
    this.failure,
  });

  final bool isLoading;
  final List<Transaction> transactions;
  final Failure? failure;

  @override
  List<Object?> get props => [isLoading, transactions, failure];
}

class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  CategoryDetailCubit(this._repository) : super(const CategoryDetailState());

  final CategoryRepository _repository;

  Future<void> load(int categoryId) async {
    emit(const CategoryDetailState(isLoading: true));
    final result = await _repository.getCategoryTransactions(categoryId);
    result.when(
      success: (transactions) => emit(
        CategoryDetailState(isLoading: false, transactions: transactions),
      ),
      failure: (failure) => emit(
        CategoryDetailState(isLoading: false, failure: failure),
      ),
    );
  }
}