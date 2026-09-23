import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.period = 'month',
    this.data,
    this.quickStats,
    this.failure,
    this.isRefreshing = false,
  });

  final DashboardStatus status;
  final String period;
  final DashboardData? data;
  final QuickStats? quickStats;
  final Failure? failure;
  final bool isRefreshing;

  DashboardState copyWith({
    DashboardStatus? status,
    String? period,
    DashboardData? Function()? data,
    QuickStats? Function()? quickStats,
    Failure? Function()? failure,
    bool? isRefreshing,
  }) {
    return DashboardState(
      status: status ?? this.status,
      period: period ?? this.period,
      data: data != null ? data() : this.data,
      quickStats: quickStats != null ? quickStats() : this.quickStats,
      failure: failure != null ? failure() : this.failure,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        data,
        quickStats,
        failure,
        isRefreshing,
      ];
}

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}

class DashboardStarted extends DashboardEvent {
  const DashboardStarted([this.period = 'month']);
  final String period;
  @override
  List<Object?> get props => [period];
}

class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
  @override
  List<Object?> get props => [];
}

class DashboardPeriodChanged extends DashboardEvent {
  const DashboardPeriodChanged(this.period);
  final String period;
  @override
  List<Object?> get props => [period];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onRefreshed);
    on<DashboardPeriodChanged>(_onPeriodChanged);
  }

  final DashboardRepository _repository;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.data != null && state.period == event.period) return;
    await _load(emit, event.period);
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    await _load(emit, state.period, isRefresh: true);
  }

  Future<void> _onPeriodChanged(
    DashboardPeriodChanged event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.period == event.period) return;
    if (state.data == null) {
      await _load(emit, event.period);
      return;
    }
    emit(state.copyWith(period: event.period, isRefreshing: true));
    await _load(emit, event.period, keepData: true);
  }

  Future<void> _load(
    Emitter<DashboardState> emit,
    String period, {
    bool isRefresh = false,
    bool keepData = false,
  }) async {
    final hasData = keepData || state.data != null;
    emit(
      state.copyWith(
        status: hasData
            ? DashboardStatus.loaded
            : DashboardStatus.loading,
        period: period,
        failure: () => null,
        isRefreshing: isRefresh,
      ),
    );

    final results = await Future.wait<Object>([
      _repository.getDashboard(period: period),
      _repository.getQuickStats(),
    ]);

    final dataResult = results[0] as Result<DashboardData>;
    final statsResult = results[1] as Result<QuickStats>;

    if (dataResult is Err) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          failure: () => dataResult.failureOrNull,
          isRefreshing: false,
        ),
      );
      return;
    }
    if (statsResult is Err) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          failure: () => statsResult.failureOrNull,
          isRefreshing: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DashboardStatus.loaded,
        data: () => dataResult.valueOrNull,
        quickStats: () => statsResult.valueOrNull,
        failure: () => null,
        isRefreshing: false,
      ),
    );
  }
}