import 'package:equatable/equatable.dart';

sealed class ActivateAccountEvent extends Equatable {
  const ActivateAccountEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ActivateAccountSubmitted extends ActivateAccountEvent {
  const ActivateAccountSubmitted({
    required this.activationToken,
    required this.password,
    required this.confirmPassword,
  });

  final String activationToken;
  final String password;
  final String confirmPassword;

  @override
  List<Object?> get props => <Object?>[activationToken, password, confirmPassword];
}
