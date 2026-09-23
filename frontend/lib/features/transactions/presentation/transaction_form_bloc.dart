import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFormState extends Equatable {
  const TransactionFormState({
    this.isSubmitting = false,
    this.result,
    this.failure,
    this.fieldErrors = const {},
  });

  final bool isSubmitting;
  final Transaction? result;
  final Failure? failure;
  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [
        isSubmitting,
        result,
        failure,
        fieldErrors,
      ];
}

sealed class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();
}

class TransactionFormSubmitted extends TransactionFormEvent {
  const TransactionFormSubmitted({this.id, required this.payload});

  final int? id;
  final TransactionPayload payload;

  @override
  List<Object?> get props => [id, payload];
}

class TransactionFormReset extends TransactionFormEvent {
  const TransactionFormReset();
  @override
  List<Object?> get props => [];
}

class TransactionFormBloc extends Bloc<TransactionFormEvent, TransactionFormState> {
  TransactionFormBloc(this._repository) : super(const TransactionFormState()) {
    on<TransactionFormSubmitted>(_onSubmitted);
    on<TransactionFormReset>((event, emit) => emit(const TransactionFormState()));
  }

  final TransactionRepository _repository;

  Future<void> _onSubmitted(
    TransactionFormSubmitted event,
    Emitter<TransactionFormState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(const TransactionFormState(isSubmitting: true));

    final result = event.id == null
        ? await _repository.createTransaction(event.payload)
        : await _repository.updateTransaction(event.id!, event.payload);

    result.when(
      success: (transaction) => emit(
        TransactionFormState(result: transaction),
      ),
      failure: (failure) => emit(
        TransactionFormState(
          failure: failure,
          fieldErrors: failure is ValidationFailure
              ? failure.fieldErrors
              : const {},
        ),
      ),
    );
  }
}