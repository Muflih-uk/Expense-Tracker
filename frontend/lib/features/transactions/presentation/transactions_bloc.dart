import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/network/paged_result.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TransactionsStatus { initial, loading, loaded, failure, loadingMore }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.items = const [],
    this.count = 0,
    this.hasMore = false,
    this.page = 0,
    this.filter = const TransactionFilter(),
    this.failure,
    this.summary,
  });

  final TransactionsStatus status;
  final List<Transaction> items;
  final int count;
  final bool hasMore;
  final int page;
  final TransactionFilter filter;
  final Failure? failure;
  final TxSummaryResponse? summary;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<Transaction>? items,
    int? count,
    bool? hasMore,
    int? page,
    TransactionFilter? filter,
    Failure? Function()? failure,
    TxSummaryResponse? Function()? summary,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      items: items ?? this.items,
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      filter: filter ?? this.filter,
      failure: failure != null ? failure() : this.failure,
      summary: summary != null ? summary() : this.summary,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        count,
        hasMore,
        page,
        filter,
        failure,
        summary,
      ];
}

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();
}

class TransactionsStarted extends TransactionsEvent {
  const TransactionsStarted([this.filter = const TransactionFilter()]);
  final TransactionFilter filter;
  @override
  List<Object?> get props => [filter];
}

class TransactionsRefreshed extends TransactionsEvent {
  const TransactionsRefreshed();
  @override
  List<Object?> get props => [];
}

class TransactionsFilterChanged extends TransactionsEvent {
  const TransactionsFilterChanged(this.filter);
  final TransactionFilter filter;
  @override
  List<Object?> get props => [filter];
}

class TransactionsSearchChanged extends TransactionsEvent {
  const TransactionsSearchChanged(this.search);
  final String search;
  @override
  List<Object?> get props => [search];
}

class TransactionsLoadMore extends TransactionsEvent {
  const TransactionsLoadMore();
  @override
  List<Object?> get props => [];
}

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._repository) : super(const TransactionsState()) {
    on<TransactionsStarted>(_onStarted);
    on<TransactionsRefreshed>(_onRefreshed);
    on<TransactionsFilterChanged>(_onFilterChanged);
    on<TransactionsSearchChanged>(_onSearchChanged);
    on<TransactionsLoadMore>(_onLoadMore);
  }

  final TransactionRepository _repository;

  Future<void> _onStarted(
    TransactionsStarted event,
    Emitter<TransactionsState> emit,
  ) async {
    if (event.filter == state.filter && state.items.isNotEmpty) return;
    emit(
      state.copyWith(
        status: TransactionsStatus.loading,
        filter: event.filter,
        failure: () => null,
      ),
    );
    await _fetch(emit, event.filter, page: 1, replace: true);
  }

  Future<void> _onRefreshed(
    TransactionsRefreshed event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TransactionsStatus.loading,
        failure: () => null,
      ),
    );
    await _fetch(emit, state.filter, page: 1, replace: true);
  }

  Future<void> _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TransactionsStatus.loading,
        filter: event.filter,
        failure: () => null,
      ),
    );
    await _fetch(emit, event.filter, page: 1, replace: true);
  }

  Future<void> _onSearchChanged(
    TransactionsSearchChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    final filter = state.filter.copyWith(search: event.search);
    emit(
      state.copyWith(
        status: TransactionsStatus.loading,
        filter: filter,
        failure: () => null,
      ),
    );
    await _fetch(emit, filter, page: 1, replace: true);
  }

  Future<void> _onLoadMore(
    TransactionsLoadMore event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state.status == TransactionsStatus.loading ||
        state.status == TransactionsStatus.loadingMore ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    emit(state.copyWith(status: TransactionsStatus.loadingMore));
    await _fetch(emit, state.filter, page: state.page + 1, replace: false);
  }

  Future<void> _fetch(
    Emitter<TransactionsState> emit,
    TransactionFilter filter, {
    required int page,
    required bool replace,
  }) async {
    final listFuture = _fetchList(filter, page);
    final wantsSummary = !filter.hasCustomRange && filter.period != 'all';

    Result<PagedResult<Transaction>> listResult;
    TxSummaryResponse? summary;

    if (wantsSummary) {
      final summaryFuture = _repository.getSummary(period: filter.period);
      final results = await Future.wait<Object>([listFuture, summaryFuture]);
      listResult = results[0] as Result<PagedResult<Transaction>>;
      final summaryResult = results[1] as Result<TxSummaryResponse>;
      summary = summaryResult.valueOrNull;
    } else {
      listResult = await listFuture;
      summary = null;
    }

    if (listResult is Err) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          failure: () => listResult.failureOrNull,
        ),
      );
      return;
    }

    final pageResult = listResult.valueOrNull!;
    final merged = replace
        ? pageResult.results
        : [...state.items, ...pageResult.results];

    emit(
      state.copyWith(
        status: TransactionsStatus.loaded,
        items: merged,
        count: pageResult.count,
        hasMore: pageResult.hasNext,
        page: page,
        filter: filter,
        failure: () => null,
        summary: () => summary,
      ),
    );
  }

  Future<Result<PagedResult<Transaction>>> _fetchList(
    TransactionFilter filter,
    int page,
  ) {
    if (filter.hasCustomRange) {
      return _repository.getDateRange(
        startDate: filter.dateFrom!,
        endDate: filter.dateTo!,
        transactionType: filter.type == 'all' ? null : filter.type,
        category: filter.categoryId,
        account: filter.accountId,
        page: page,
        ordering: filter.ordering,
      );
    }
    switch (filter.type) {
      case 'income':
        return _repository.getIncome(filter: filter, page: page);
      case 'expense':
        return _repository.getExpenses(filter: filter, page: page);
      default:
        return _repository.getTransactions(filter: filter, page: page);
    }
  }
}