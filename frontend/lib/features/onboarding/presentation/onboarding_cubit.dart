import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/storage/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingState extends Equatable {
  const OnboardingState({this.isLoading = true, this.isComplete = false});

  final bool isLoading;
  final bool isComplete;

  @override
  List<Object?> get props => [isLoading, isComplete];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._storage) : super(const OnboardingState());

  final LocalStorage _storage;

  void load() {
    emit(
      OnboardingState(
        isLoading: false,
        isComplete: _storage.isOnboardingComplete,
      ),
    );
  }

  Future<void> complete() async {
    await _storage.setOnboardingComplete();
    emit(const OnboardingState(isLoading: false, isComplete: true));
  }
}