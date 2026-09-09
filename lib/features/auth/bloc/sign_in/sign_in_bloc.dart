import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/sign_in/sign_in_event.dart';
import 'package:newlane/features/auth/bloc/sign_in/sign_in_state.dart';
import 'package:newlane/features/auth/domain/usecases/login.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required Login login})
    : _login = login,
      super(const SignInInitial()) {
    on<SignInSubmitted>(_onSubmitted);
  }

  final Login _login;
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    if (state is SignInLoading) return;

    final String? validationError = _validate(event);
    if (validationError != null) {
      // Reset first so identical validation errors re-trigger the listener.
      emit(const SignInInitial());
      emit(SignInFailure(message: validationError, isValidation: true));
      return;
    }

    emit(const SignInLoading());

    final result = await _login(
      LoginParams(
        email: event.email.trim(),
        password: event.password,
        rememberMe: event.rememberMe,
      ),
    );

    result.when(
      ok: (value) {
        AppLog.line('[BLOC] sign in success status=${value.status}');
        if (value.token.isEmpty) {
          emit(
            const SignInFailure(
              message: 'No auth token returned. Please try again.',
            ),
          );
          return;
        }
        emit(SignInSuccess(value));
      },
      err: (failure) {
        AppLog.line('[BLOC] sign in failed: ${failure.message}');
        emit(
          SignInFailure(
            message: failure.message,
            isValidation: failure is ValidationFailure,
          ),
        );
      },
    );
  }

  String? _validate(SignInSubmitted event) {
    if (event.email.trim().isEmpty) {
      return 'Please enter your company email.';
    }
    if (!_emailRegex.hasMatch(event.email.trim())) {
      return 'Please enter a valid email address.';
    }
    if (event.password.isEmpty) {
      return 'Please enter your password.';
    }
    return null;
  }
}
