import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/reset_password_result.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object?> get props => <Object?>[];
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess(this.result);

  final ResetPasswordResult result;

  @override
  List<Object?> get props => <Object?>[result];
}

class ResetPasswordFailure extends ResetPasswordState {
  const ResetPasswordFailure({
    required this.message,
    this.isValidation = false,
  });

  final String message;
  final bool isValidation;

  @override
  List<Object?> get props => <Object?>[message, isValidation];
}
