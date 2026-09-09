import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/login_result.dart';

sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => <Object?>[];
}

class SignInInitial extends SignInState {
  const SignInInitial();
}

class SignInLoading extends SignInState {
  const SignInLoading();
}

class SignInSuccess extends SignInState {
  const SignInSuccess(this.result);

  final LoginResult result;

  @override
  List<Object?> get props => <Object?>[result];
}

class SignInFailure extends SignInState {
  const SignInFailure({
    required this.message,
    this.isValidation = false,
  });

  final String message;
  final bool isValidation;

  @override
  List<Object?> get props => <Object?>[message, isValidation];
}
