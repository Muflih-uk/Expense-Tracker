import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AccountsStatus { initial, loading, loaded, failure }

class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.summary,
    this.failure,
    this.isMutating = false,
  });

  final AccountsStatus status;
  final List<Account> accounts;
  final AccountSummary? summary;
  final Failure? failure;
  final bool isMutating;

  AccountsState copyWith({
    AccountsStatus? status,
    List<Account>? accounts,
    AccountSummary? Function()? summary,
    Failure? Function()? failure,
    bool? isMutating,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      summary: summary != null ? summary() : this.summary,
      failure: failure != null ? failure() : this.failure,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => [status, accounts, summary, failure, isMutating];
}

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();
}

class AccountsLoaded extends AccountsEvent {
  const AccountsLoaded();
  @override
  List<Object?> get props => [];
}

class AccountsRefreshed extends AccountsEvent {
  const AccountsRefreshed();
  @override
  List<Object?> get props => [];
}

class AccountCreated extends AccountsEvent {
  const AccountCreated({required this.title, required this.initial});
  final String title;
  final double initial;
  @override
  List<Object?> get props => [title, initial];
}

class AccountDeleted extends AccountsEvent {
  const AccountDeleted(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc(this._repository) : super(const AccountsState()) {
    on<AccountsLoaded>(_onLoaded);
    on<AccountsRefreshed>(_onRefreshed);
    on<AccountCreated>(_onCreated);
    on<AccountDeleted>(_onDeleted);
  }

  final AccountRepository _repository;

  Future<void> _onLoaded(
    AccountsLoaded event,
    Emitter<AccountsState> emit,
  ) async {
    if (state.accounts.isNotEmpty) return;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(
    AccountsRefreshed event,
    Emitter<AccountsState> emit,
  ) async {
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<AccountsState> emit) async {
    emit(state.copyWith(status: AccountsStatus.loading, failure: () => null));
    final results = await Future.wait<Object>([
      _repository.getAccountsWithBalance(),
      _repository.getAccountSummary(),
    ]);
    final accountsResult = results[0] as Result<List<Account>>;
    final summaryResult = results[1] as Result<AccountSummary>;

    if (accountsResult is Err) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          failure: () => accountsResult.failureOrNull,
        ),
      );
      return;
    }
    if (summaryResult is Err) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          failure: () => summaryResult.failureOrNull,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: AccountsStatus.loaded,
        accounts: accountsResult.valueOrNull ?? const [],
        summary: () => summaryResult.valueOrNull,
        failure: () => null,
      ),
    );
  }

  Future<void> _onCreated(
    AccountCreated event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, failure: () => null));
    final result = await _repository.createAccount(
      title: event.title,
      initial: event.initial,
    );
    if (result is Err) {
      emit(
        state.copyWith(
          isMutating: false,
          failure: () => result.failureOrNull,
        ),
      );
      return;
    }
    emit(state.copyWith(isMutating: false));
    await _fetch(emit);
  }

  Future<void> _onDeleted(
    AccountDeleted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, failure: () => null));
    final result = await _repository.deleteAccount(event.id);
    if (result is Err) {
      emit(
        state.copyWith(
          isMutating: false,
          failure: () => result.failureOrNull,
        ),
      );
      return;
    }
    emit(state.copyWith(isMutating: false));
    await _fetch(emit);
  }
}