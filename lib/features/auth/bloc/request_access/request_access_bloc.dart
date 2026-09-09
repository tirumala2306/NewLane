import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/request_access/request_access_event.dart';
import 'package:newlane/features/auth/bloc/request_access/request_access_state.dart';
import 'package:newlane/features/auth/domain/usecases/submit_access_request.dart';

class RequestAccessBloc extends Bloc<RequestAccessEvent, RequestAccessState> {
  RequestAccessBloc({required SubmitAccessRequest submitAccessRequest})
    : _submitAccessRequest = submitAccessRequest,
      super(const RequestAccessInitial()) {
    on<RequestAccessSubmitted>(_onSubmitted);
  }

  final SubmitAccessRequest _submitAccessRequest;
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  Future<void> _onSubmitted(
    RequestAccessSubmitted event,
    Emitter<RequestAccessState> emit,
  ) async {
    if (state is RequestAccessLoading) return;

    final String? validationError = _validate(event);
    if (validationError != null) {
      AppLog.line('[BLOC] validation failed: $validationError');
      emit(
        RequestAccessFailure(
          title: 'Please Fill All Fields',
          message: validationError,
          isValidation: true,
        ),
      );
      return;
    }

    emit(const RequestAccessLoading());

    final result = await _submitAccessRequest(
      SubmitAccessRequestParams(
        fullName: event.fullName.trim(),
        workEmail: event.workEmail.trim(),
        brokerageName: event.brokerageName.trim(),
        phone: event.phone.trim(),
      ),
    );

    result.when(
      ok: (value) {
        AppLog.line('[BLOC] submit success id=${value.requestId}');
        emit(RequestAccessSuccess(value));
      },
      err: (failure) {
        AppLog.line('[BLOC] submit failed: ${failure.message}');
        emit(
          RequestAccessFailure(
            title: failure is NetworkFailure
                ? 'Unable to Continue'
                : 'Request Failed',
            message: failure.message,
          ),
        );
      },
    );
  }

  String? _validate(RequestAccessSubmitted event) {
    if (event.fullName.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (event.workEmail.trim().isEmpty) {
      return 'Please enter your work email.';
    }
    if (!_emailRegex.hasMatch(event.workEmail.trim())) {
      return 'Please enter a valid work email.';
    }
    if (event.brokerageName.trim().isEmpty) {
      return 'Please enter your office / brokerage name.';
    }
    if (event.phone.trim().isEmpty) {
      return 'Please enter your phone number.';
    }
    if (!event.acceptedTerms) {
      return 'Please agree to the Terms & Conditions and Privacy Policy.';
    }
    return null;
  }
}
