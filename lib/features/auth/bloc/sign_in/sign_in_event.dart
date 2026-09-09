import 'package:equatable/equatable.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class SignInSubmitted extends SignInEvent {
  const SignInSubmitted({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final bool rememberMe;

  @override
  List<Object?> get props => <Object?>[email, password, rememberMe];
}
