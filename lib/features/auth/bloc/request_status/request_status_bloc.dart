import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/domain/entities/access_request_status.dart';
import 'package:newlane/features/auth/domain/usecases/get_access_request_status.dart';

part 'request_status_event.dart';
part 'request_status_state.dart';

class RequestStatusBloc extends Bloc<RequestStatusEvent, RequestStatusState> {
  RequestStatusBloc({required GetAccessRequestStatus getAccessRequestStatus})
    : _getAccessRequestStatus = getAccessRequestStatus,
      super(const RequestStatusInitial()) {
    on<RequestStatusStarted>(_onStarted);
  }

  static const Duration _pollEvery = Duration(seconds: 8);

  final GetAccessRequestStatus _getAccessRequestStatus;
  Timer? _pollTimer;

  Future<void> _onStarted(
    RequestStatusStarted event,
    Emitter<RequestStatusState> emit,
  ) async {
    final result = await _getAccessRequestStatus(const NoParams());

    result.when(
      ok: (status) {
        AppLog.line('[BLOC] status loaded → $status');
        emit(RequestStatusLoaded(status));
        _syncPoll(status);
      },
      err: (failure) {
        AppLog.line('[BLOC] status failed: ${failure.message}');
        if (event.silent && state is RequestStatusLoaded) return;
        emit(RequestStatusFailure(failure.message));
      },
    );
  }

  /// Keep checking while the office is still reviewing.
  void _syncPoll(AccessRequestStatus status) {
    if (status.isPending || status.status == AccessRequestStatusType.unknown) {
      _pollTimer ??= Timer.periodic(_pollEvery, (_) {
        add(const RequestStatusStarted(silent: true));
      });
      return;
    }
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
