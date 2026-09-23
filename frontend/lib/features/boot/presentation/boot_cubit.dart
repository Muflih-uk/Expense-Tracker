import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/boot/data/boot_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum BootStatus { connecting, ready, failed }

class BootState extends Equatable {
  const BootState({
    this.status = BootStatus.connecting,
    this.failure,
    this.version,
    this.attempts = 0,
  });

  final BootStatus status;
  final Failure? failure;
  final String? version;
  final int attempts;

  bool get isConnecting => status == BootStatus.connecting;
  bool get isReady => status == BootStatus.ready;
  bool get isFailed => status == BootStatus.failed;

  BootState copyWith({
    BootStatus? status,
    Failure? Function()? failure,
    String? Function()? version,
    int? attempts,
  }) {
    return BootState(
      status: status ?? this.status,
      failure: failure != null ? failure() : this.failure,
      version: version != null ? version() : this.version,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  List<Object?> get props => [status, failure, version, attempts];
}

class BootCubit extends Cubit<BootState> {
  BootCubit(this._dataSource) : super(const BootState());

  static const _minDisplay = Duration(milliseconds: 1500);

  final BootDataSource _dataSource;

  Future<void> start() async {
    if (state.isReady) return;
    emit(
      state.copyWith(
        status: BootStatus.connecting,
        failure: () => null,
      ),
    );
    final started = DateTime.now();

    try {
      final version = await _dataSource.checkServer();
      final elapsed = DateTime.now().difference(started);
      final remaining = _minDisplay - elapsed;
      if (remaining > Duration.zero && !isClosed) {
        await Future.delayed(remaining);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BootStatus.ready,
          version: () => version,
        ),
      );
    } on AppException catch (error) {
      if (!isClosed) await Future.delayed(_minDisplay);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BootStatus.failed,
          failure: () => error.toFailure(),
          attempts: state.attempts + 1,
        ),
      );
    } on Exception {
      if (!isClosed) await Future.delayed(_minDisplay);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: BootStatus.failed,
          failure: () => const ServerFailure('Unable to reach server'),
          attempts: state.attempts + 1,
        ),
      );
    }
  }
}