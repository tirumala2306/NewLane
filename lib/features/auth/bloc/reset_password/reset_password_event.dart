import 'package:equatable/equatable.dart';

sealed class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted({
    required this.resetToken,
    required this.password,
    required this.confirmPassword,
  });

  final String resetToken;
  final String password;
  final String confirmPassword;

  @override
  List<Object?> get props => <Object?>[resetToken, password, confirmPassword];
}
