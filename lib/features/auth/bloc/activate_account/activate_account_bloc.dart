import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/activate_account/activate_account_event.dart';
import 'package:newlane/features/auth/bloc/activate_account/activate_account_state.dart';
import 'package:newlane/features/auth/domain/usecases/activate_account.dart';

class ActivateAccountBloc extends Bloc<ActivateAccountEvent, ActivateAccountState> {
  ActivateAccountBloc({required ActivateAccount activateAccount})
    : _activateAccount = activateAccount,
      super(const ActivateAccountInitial()) {
    on<ActivateAccountSubmitted>(_onSubmitted);
  }

  final ActivateAccount _activateAccount;

  static final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%]).{8,}$',
  );

  Future<void> _onSubmitted(
    ActivateAccountSubmitted event,
    Emitter<ActivateAccountState> emit,
  ) async {
    if (state is ActivateAccountLoading) return;

    final String? validationError = _validate(event);
    if (validationError != null) {
      emit(ActivateAccountFailure(message: validationError, isValidation: true));
      return;
    }

    emit(const ActivateAccountLoading());

    final result = await _activateAccount(
      ActivateAccountParams(
        activationToken: event.activationToken,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.when(
      ok: (value) {
        AppLog.line('[BLOC] account activated');
        emit(ActivateAccountSuccess(value));
      },
      err: (failure) {
        AppLog.line('[BLOC] activate failed: ${failure.message}');
        emit(
          ActivateAccountFailure(
            message: failure.message,
            isValidation: failure is ValidationFailure,
          ),
        );
      },
    );
  }

  String? _validate(ActivateAccountSubmitted event) {
    if (event.activationToken.trim().isEmpty) {
      return 'Activation link is invalid. Open the link from your email again.';
    }
    if (event.password.isEmpty || event.confirmPassword.isEmpty) {
      return 'Please enter and confirm your password.';
    }
    if (event.password != event.confirmPassword) {
      return 'Passwords do not match.';
    }
    if (!_passwordPattern.hasMatch(event.password)) {
      return 'Password must be at least 8 characters and include an uppercase letter, a number, and a special character (!@#\$%).';
    }
    return null;
  }
}
