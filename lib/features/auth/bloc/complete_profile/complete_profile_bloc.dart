import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_event.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_state.dart';
import 'package:newlane/features/auth/domain/usecases/complete_profile.dart';
import 'package:newlane/features/auth/domain/usecases/get_agent_me.dart';

class CompleteProfileBloc
    extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  CompleteProfileBloc({
    required CompleteProfile completeProfile,
    required GetAgentMe getAgentMe,
  }) : _completeProfile = completeProfile,
       _getAgentMe = getAgentMe,
       super(const CompleteProfileInitial()) {
    on<CompleteProfileStarted>(_onStarted);
    on<CompleteProfileSubmitted>(_onSubmitted);
  }

  final CompleteProfile _completeProfile;
  final GetAgentMe _getAgentMe;

  Future<void> _onStarted(
    CompleteProfileStarted event,
    Emitter<CompleteProfileState> emit,
  ) async {
    final result = await _getAgentMe(const NoParams());
    result.when(
      ok: (profile) {
        AppLog.line('[BLOC] agent profile loaded');
        emit(CompleteProfileReady(profile: profile));
      },
      err: (failure) {
        AppLog.line('[BLOC] get agent me failed: ${failure.message}');
        // Still allow editing with local/request-access values.
        emit(const CompleteProfileReady());
      },
    );
  }

  Future<void> _onSubmitted(
    CompleteProfileSubmitted event,
    Emitter<CompleteProfileState> emit,
  ) async {
    if (state is CompleteProfileLoading) return;

    final String? validationError = _validate(event);
    if (validationError != null) {
      emit(
        CompleteProfileFailure(message: validationError, isValidation: true),
      );
      return;
    }

    emit(const CompleteProfileLoading());

    final result = await _completeProfile(
      CompleteProfileParams(
        fullName: event.fullName.trim(),
        phone: event.phone.trim(),
        jobTitle: event.jobTitle.trim(),
        bio: event.bio.trim(),
        instagram: event.instagram.trim(),
        website: event.website.trim(),
        specialties: event.specialties
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .toList(),
        avatarFilePath: event.avatarFilePath,
      ),
    );

    result.when(
      ok: (value) {
        AppLog.line('[BLOC] profile completed');
        emit(CompleteProfileSuccess(value));
      },
      err: (failure) {
        AppLog.line('[BLOC] complete profile failed: ${failure.message}');
        emit(
          CompleteProfileFailure(
            message: failure.message,
            isValidation: failure is ValidationFailure,
          ),
        );
      },
    );
  }

  String? _validate(CompleteProfileSubmitted event) {
    if (event.fullName.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (event.phone.trim().isEmpty) {
      return 'Please enter your phone number.';
    }
    if (event.jobTitle.trim().isEmpty) {
      return 'Job title is not set on your account yet. Contact your office manager.';
    }
    final List<String> specialties = event.specialties
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    if (specialties.isEmpty) {
      return 'Please add at least one specialty.';
    }
    if (event.bio.trim().isEmpty) {
      return 'Please enter a short bio.';
    }
    return null;
  }
}
