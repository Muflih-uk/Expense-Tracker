import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionDetailState extends Equatable {
  const TransactionDetailState({
    this.isLoading = false,
    this.transaction,
    this.isDeleting = false,
    this.deleted = false,
    this.failure,
  });

  final bool isLoading;
  final Transaction? transaction;
  final bool isDeleting;
  final bool deleted;
  final Failure? failure;

  TransactionDetailState copyWith({
    bool? isLoading,
    Transaction? Function()? transaction,
    bool? isDeleting,
    bool? deleted,
    Failure? Function()? failure,
  }) {
    return TransactionDetailState(
      isLoading: isLoading ?? this.isLoading,
      transaction: transaction != null ? transaction() : this.transaction,
      isDeleting: isDeleting ?? this.isDeleting,
      deleted: deleted ?? this.deleted,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        transaction,
        isDeleting,
        deleted,
        failure,
      ];
}

class TransactionDetailCubit extends Cubit<TransactionDetailState> {
  TransactionDetailCubit(this._repository) : super(const TransactionDetailState());

  final TransactionRepository _repository;

  Future<void> load(int id) async {
    emit(const TransactionDetailState(isLoading: true));
    final result = await _repository.getTransaction(id);
    result.when(
      success: (transaction) => emit(
        TransactionDetailState(transaction: transaction),
      ),
      failure: (failure) => emit(
        TransactionDetailState(failure: failure),
      ),
    );
  }

  Future<void> delete(int id) async {
    emit(state.copyWith(isDeleting: true, failure: () => null));
    final result = await _repository.deleteTransaction(id);
    result.when(
      success: (_) => emit(state.copyWith(isDeleting: false, deleted: true)),
      failure: (failure) => emit(
        state.copyWith(isDeleting: false, failure: () => failure),
      ),
    );
  }
}