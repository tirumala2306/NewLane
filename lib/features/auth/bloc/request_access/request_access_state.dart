import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/access_request_result.dart';

sealed class RequestAccessState extends Equatable {
  const RequestAccessState();

  @override
  List<Object?> get props => <Object?>[];
}

class RequestAccessInitial extends RequestAccessState {
  const RequestAccessInitial();
}

class RequestAccessLoading extends RequestAccessState {
  const RequestAccessLoading();
}

class RequestAccessSuccess extends RequestAccessState {
  const RequestAccessSuccess(this.result);

  final AccessRequestResult result;

  @override
  List<Object?> get props => <Object?>[result.requestId, result.message];
}

class RequestAccessFailure extends RequestAccessState {
  const RequestAccessFailure({
    required this.title,
    required this.message,
    this.isValidation = false,
  });

  final String title;
  final String message;
  final bool isValidation;

  @override
  List<Object?> get props => <Object?>[title, message, isValidation];
}
