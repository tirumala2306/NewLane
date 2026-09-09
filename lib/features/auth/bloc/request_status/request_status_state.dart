part of 'request_status_bloc.dart';

sealed class RequestStatusState extends Equatable {
  const RequestStatusState();

  @override
  List<Object?> get props => <Object?>[];
}

class RequestStatusInitial extends RequestStatusState {
  const RequestStatusInitial();
}

class RequestStatusLoading extends RequestStatusState {
  const RequestStatusLoading();
}

class RequestStatusLoaded extends RequestStatusState {
  const RequestStatusLoaded(this.status);

  final AccessRequestStatus status;

  @override
  List<Object?> get props =>
      <Object?>[status.status, status.rejectionReason, status.message];
}

class RequestStatusFailure extends RequestStatusState {
  const RequestStatusFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
