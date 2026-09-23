import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CategoriesStatus { initial, loading, loaded, failure }

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.items = const [],
    this.failure,
    this.period = 'month',
    this.isMutating = false,
  });

  final CategoriesStatus status;
  final List<CategoryWithStats> items;
  final Failure? failure;
  final String period;
  final bool isMutating;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryWithStats>? items,
    Failure? Function()? failure,
    String? period,
    bool? isMutating,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure != null ? failure() : this.failure,
      period: period ?? this.period,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => [status, items, failure, period, isMutating];
}

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();
}

class CategoriesLoaded extends CategoriesEvent {
  const CategoriesLoaded([this.period = 'month']);
  final String period;
  @override
  List<Object?> get props => [period];
}

class CategoriesRefreshed extends CategoriesEvent {
  const CategoriesRefreshed();
  @override
  List<Object?> get props => [];
}

class CategoryCreated extends CategoriesEvent {
  const CategoryCreated(this.title);
  final String title;
  @override
  List<Object?> get props => [title];
}

class CategoryDeleted extends CategoriesEvent {
  const CategoryDeleted(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this._repository) : super(const CategoriesState()) {
    on<CategoriesLoaded>(_onLoaded);
    on<CategoriesRefreshed>(_onRefreshed);
    on<CategoryCreated>(_onCreated);
    on<CategoryDeleted>(_onDeleted);
  }

  final CategoryRepository _repository;

  Future<void> _onLoaded(
    CategoriesLoaded event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state.items.isNotEmpty && state.period == event.period) return;
    emit(state.copyWith(status: CategoriesStatus.loading, period: event.period));
    await _fetch(emit, event.period);
  }

  Future<void> _onRefreshed(
    CategoriesRefreshed event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    await _fetch(emit, state.period);
  }

  Future<void> _onCreated(
    CategoryCreated event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    final result = await _repository.createCategory(title: event.title);
    if (result is Err) {
      emit(
        state.copyWith(
          isMutating: false,
          failure: () => result.failureOrNull,
        ),
      );
      return;
    }
    emit(state.copyWith(isMutating: false, failure: () => null));
    await _fetch(emit, state.period);
  }

  Future<void> _onDeleted(
    CategoryDeleted event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    final result = await _repository.deleteCategory(event.id);
    if (result is Err) {
      emit(state.copyWith(isMutating: false, failure: () => result.failure));
      return;
    }
    emit(state.copyWith(isMutating: false, failure: () => null));
    await _fetch(emit, state.period);
  }

  Future<void> _fetch(
    Emitter<CategoriesState> emit,
    String period,
  ) async {
    final result = await _repository.getCategoriesWithStats(period: period);
    result.when(
      success: (items) => emit(
        state.copyWith(
          status: CategoriesStatus.loaded,
          items: items,
          failure: () => null,
        ),
      ),
      failure: (failure) => emit(
        state.copyWith(status: CategoriesStatus.failure, failure: () => failure),
      ),
    );
  }
}