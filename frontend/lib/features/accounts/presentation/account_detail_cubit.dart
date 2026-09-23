import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountDetailState extends Equatable {
  const AccountDetailState({
    this.isLoading = false,
    this.account,
    this.history,
    this.transactions = const [],
    this.failure,
    this.period = 'month',
  });

  final bool isLoading;
  final Account? account;
  final BalanceHistory? history;
  final List<Transaction> transactions;
  final Failure? failure;
  final String period;

  AccountDetailState copyWith({
    bool? isLoading,
    Account? Function()? account,
    BalanceHistory? Function()? history,
    List<Transaction>? transactions,
    Failure? Function()? failure,
    String? period,
  }) {
    return AccountDetailState(
      isLoading: isLoading ?? this.isLoading,
      account: account != null ? account() : this.account,
      history: history != null ? history() : this.history,
      transactions: transactions ?? this.transactions,
      failure: failure != null ? failure() : this.failure,
      period: period ?? this.period,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        account,
        history,
        transactions,
        failure,
        period,
      ];
}

class AccountDetailCubit extends Cubit<AccountDetailState> {
  AccountDetailCubit(this._repository) : super(const AccountDetailState());

  final AccountRepository _repository;

  Future<void> load(int accountId) async {
    emit(const AccountDetailState(isLoading: true));
    await _fetchAll(accountId, state.period);
  }

  Future<void> changePeriod(
    int accountId,
    String period,
  ) async {
    emit(state.copyWith(isLoading: true, period: period));
    await _fetchAll(accountId, period);
  }

  Future<void> _fetchAll(int accountId, String period) async {
    final results = await Future.wait<Object>([
      _repository.getAccount(accountId),
      _repository.getBalanceHistory(accountId, period: period),
      _repository.getAccountTransactions(accountId),
    ]);
    final accountResult = results[0] as Result<Account>;
    final historyResult = results[1] as Result<BalanceHistory>;
    final transactionsResult = results[2] as Result<List<Transaction>>;

    if (accountResult is Err) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: () => accountResult.failureOrNull,
        ),
      );
      return;
    }
    if (historyResult is Err) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: () => historyResult.failureOrNull,
        ),
      );
      return;
    }
    if (transactionsResult is Err) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: () => transactionsResult.failureOrNull,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        account: () => accountResult.valueOrNull,
        history: () => historyResult.valueOrNull,
        transactions: transactionsResult.valueOrNull ?? const [],
        failure: () => null,
      ),
    );
  }
}