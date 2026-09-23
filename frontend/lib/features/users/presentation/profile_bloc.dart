import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.isLoading = false,
    this.user,
    this.isUpdating = false,
    this.isDeleting = false,
    this.deleted = false,
    this.failure,
    this.fieldErrors = const {},
    this.version,
  });

  final bool isLoading;
  final User? user;
  final bool isUpdating;
  final bool isDeleting;
  final bool deleted;
  final Failure? failure;
  final Map<String, List<String>> fieldErrors;
  final String? version;

  ProfileState copyWith({
    bool? isLoading,
    User? Function()? user,
    bool? isUpdating,
    bool? isDeleting,
    bool? deleted,
    Failure? Function()? failure,
    Map<String, List<String>>? fieldErrors,
    String? Function()? version,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user != null ? user() : this.user,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      deleted: deleted ?? this.deleted,
      failure: failure != null ? failure() : this.failure,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      version: version != null ? version() : this.version,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        user,
        isUpdating,
        isDeleting,
        deleted,
        failure,
        fieldErrors,
        version,
      ];
}

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
  @override
  List<Object?> get props => [];
}

class ProfileRefreshed extends ProfileEvent {
  const ProfileRefreshed();
  @override
  List<Object?> get props => [];
}

class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated({this.name, this.email, this.password});
  final String? name;
  final String? email;
  final String? password;
  @override
  List<Object?> get props => [name, email, password];
}

class ProfileDeleted extends ProfileEvent {
  const ProfileDeleted();
  @override
  List<Object?> get props => [];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileRefreshed>(_onRefreshed);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileDeleted>(_onDeleted);
  }

  final UserRepository _repository;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user != null) return;
    emit(state.copyWith(isLoading: true));
    await _load(emit);
    final versionResult = await _repository.getVersion();
    versionResult.when(
      success: (version) => emit(state.copyWith(version: () => version)),
      failure: (_) {},
    );
  }

  Future<void> _onRefreshed(
    ProfileRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<ProfileState> emit) async {
    final result = await _repository.getCurrentUser();
    if (result is Err) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: () => result.failureOrNull,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        user: () => result.valueOrNull,
        failure: () => null,
      ),
    );
  }

  Future<void> _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    final id = state.user?.id;
    if (id == null || state.isUpdating) return;
    emit(
      state.copyWith(
        isUpdating: true,
        failure: () => null,
        fieldErrors: const {},
      ),
    );
    final result = await _repository.updateProfile(
      id: id,
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.when(
      success: (user) => emit(
        state.copyWith(
          isUpdating: false,
          user: () => user,
          failure: () => null,
        ),
      ),
      failure: (failure) => emit(
        state.copyWith(
          isUpdating: false,
          failure: () => failure,
          fieldErrors: failure is ValidationFailure
              ? failure.fieldErrors
              : const {},
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    ProfileDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    final id = state.user?.id;
    if (id == null || state.isDeleting) return;
    emit(state.copyWith(isDeleting: true, failure: () => null));
    final result = await _repository.deleteAccount(id);
    result.when(
      success: (_) => emit(state.copyWith(isDeleting: false, deleted: true)),
      failure: (failure) => emit(
        state.copyWith(isDeleting: false, failure: () => failure),
      ),
    );
  }
}