import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/forgot_password/forgot_password_event.dart';
import 'package:newlane/features/auth/bloc/forgot_password/forgot_password_state.dart';
import 'package:newlane/features/auth/domain/entities/forgot_password_result.dart';
import 'package:newlane/features/auth/domain/usecases/forgot_password.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required ForgotPassword forgotPassword})
    : _forgotPassword = forgotPassword,
      super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  final ForgotPassword _forgotPassword;
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (state is ForgotPasswordLoading) return;

    final String email = event.email.trim();
    final String? validationError = _validate(email);
    if (validationError != null) {
      emit(const ForgotPasswordInitial());
      emit(
        ForgotPasswordFailure(message: validationError, isValidation: true),
      );
      return;
    }

    emit(const ForgotPasswordLoading());

    final Result<ForgotPasswordResult> result = await _forgotPassword(
      ForgotPasswordParams(email: email),
    );

    result.when(
      ok: (ForgotPasswordResult value) {
        AppLog.line('[BLOC] forgot password success');
        emit(ForgotPasswordSuccess(value, email: email));
      },
      err: (failure) {
        AppLog.line('[BLOC] forgot password failed: ${failure.message}');
        emit(
          ForgotPasswordFailure(
            message: failure.message,
            isValidation: failure is ValidationFailure,
          ),
        );
      },
    );
  }

  String? _validate(String email) {
    if (email.isEmpty) {
      return 'Please enter your company email.';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
}
