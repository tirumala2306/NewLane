part of 'request_status_bloc.dart';

sealed class RequestStatusEvent extends Equatable {
  const RequestStatusEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class RequestStatusStarted extends RequestStatusEvent {
  const RequestStatusStarted({this.silent = false});

  /// Poll refresh — don't replace the pending UI with a spinner.
  final bool silent;

  @override
  List<Object?> get props => <Object?>[silent];
}
