import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/forgot_password_result.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => <Object?>[];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess(this.result, {required this.email});

  final ForgotPasswordResult result;
  final String email;

  @override
  List<Object?> get props => <Object?>[result, email];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure({
    required this.message,
    this.isValidation = false,
  });

  final String message;
  final bool isValidation;

  @override
  List<Object?> get props => <Object?>[message, isValidation];
}
