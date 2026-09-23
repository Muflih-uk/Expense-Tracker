import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/auth/domain/usecases/auth_usecases.dart';
import 'package:expense_tracker/features/users/domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.failure,
    this.isSubmitting = false,
    this.fieldErrors = const {},
  });

  final AuthStatus status;
  final User? user;
  final Failure? failure;
  final bool isSubmitting;
  final Map<String, List<String>> fieldErrors;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? Function()? user,
    Failure? Function()? failure,
    bool? isSubmitting,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user != null ? user() : this.user,
      failure: failure != null ? failure() : this.failure,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [status, user, failure, isSubmitting, fieldErrors];
}

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
  @override
  List<Object?> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
  @override
  List<Object?> get props => [];
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
  @override
  List<Object?> get props => [];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required RestoreSession restoreSession,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _restoreSession = restoreSession,
        super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final RestoreSession _restoreSession;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthState());
    final result = await _restoreSession(const NoParams());
    result.when(
      success: (session) {
        if (session == null) {
          emit(const AuthState(status: AuthStatus.unauthenticated));
        } else {
          emit(
            AuthState(status: AuthStatus.authenticated, user: session.user),
          );
        }
      },
      failure: (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
    );
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        isSubmitting: true,
        failure: () => null,
        fieldErrors: const {},
      ),
    );
    final result = await _signIn(
      SignInParams(email: event.email, password: event.password),
    );
    result.when(
      success: (session) => emit(
        AuthState(status: AuthStatus.authenticated, user: session.user),
      ),
      failure: (failure) => emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          failure: failure,
          fieldErrors: failure is ValidationFailure
              ? failure.fieldErrors
              : const {},
        ),
      ),
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        isSubmitting: true,
        failure: () => null,
        fieldErrors: const {},
      ),
    );
    final result = await _signUp(
      SignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    result.when(
      success: (session) => emit(
        AuthState(status: AuthStatus.authenticated, user: session.user),
      ),
      failure: (failure) => emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          failure: failure,
          fieldErrors: failure is ValidationFailure
              ? failure.fieldErrors
              : const {},
        ),
      ),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        failure: AuthFailure('Session expired, please sign in again'),
      ),
    );
  }
}