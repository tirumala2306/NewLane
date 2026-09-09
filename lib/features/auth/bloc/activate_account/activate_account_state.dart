import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/activate_account_result.dart';

sealed class ActivateAccountState extends Equatable {
  const ActivateAccountState();

  @override
  List<Object?> get props => <Object?>[];
}

class ActivateAccountInitial extends ActivateAccountState {
  const ActivateAccountInitial();
}

class ActivateAccountLoading extends ActivateAccountState {
  const ActivateAccountLoading();
}

class ActivateAccountSuccess extends ActivateAccountState {
  const ActivateAccountSuccess(this.result);

  final ActivateAccountResult result;

  @override
  List<Object?> get props => <Object?>[result];
}

class ActivateAccountFailure extends ActivateAccountState {
  const ActivateAccountFailure({
    required this.message,
    this.isValidation = false,
  });

  final String message;
  final bool isValidation;

  @override
  List<Object?> get props => <Object?>[message, isValidation];
}
