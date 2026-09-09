import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/reset_password/reset_password_event.dart';
import 'package:newlane/features/auth/bloc/reset_password/reset_password_state.dart';
import 'package:newlane/features/auth/domain/entities/reset_password_result.dart';
import 'package:newlane/features/auth/domain/usecases/reset_password.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc({required ResetPassword resetPassword})
    : _resetPassword = resetPassword,
      super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  final ResetPassword _resetPassword;

  static final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%]).{8,}$',
  );

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    if (state is ResetPasswordLoading) return;

    final String? validationError = _validate(event);
    if (validationError != null) {
      emit(const ResetPasswordInitial());
      emit(
        ResetPasswordFailure(message: validationError, isValidation: true),
      );
      return;
    }

    emit(const ResetPasswordLoading());

    final Result<ResetPasswordResult> result = await _resetPassword(
      ResetPasswordParams(
        resetToken: event.resetToken.trim(),
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.when(
      ok: (ResetPasswordResult value) {
        AppLog.line('[BLOC] password reset success');
        emit(ResetPasswordSuccess(value));
      },
      err: (failure) {
        AppLog.line('[BLOC] password reset failed: ${failure.message}');
        emit(
          ResetPasswordFailure(
            message: failure.message,
            isValidation: failure is ValidationFailure,
          ),
        );
      },
    );
  }

  String? _validate(ResetPasswordSubmitted event) {
    if (event.resetToken.trim().isEmpty) {
      return 'Reset link is invalid. Open the link from your email again.';
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
