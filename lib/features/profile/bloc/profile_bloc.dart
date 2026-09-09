import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/domain/usecases/get_agent_me.dart';
import 'package:newlane/features/profile/bloc/profile_event.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required GetAgentMe getAgentMe})
    : _getAgentMe = getAgentMe,
      super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  final GetAgentMe _getAgentMe;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoading) return;

    // Keep cached profile unless an explicit refresh is requested.
    if (!event.force && state is ProfileLoaded) {
      AppLog.line('[BLOC] profile cache hit — skip GET /api/agents/me');
      return;
    }

    final ProfileLoaded? previous =
        state is ProfileLoaded ? state as ProfileLoaded : null;

    // Silent refresh when we already have data — avoid UI flicker.
    if (previous == null) {
      emit(const ProfileLoading());
    }
    AppLog.line(
      '[BLOC] profile GET /api/agents/me force=${event.force}',
    );

    final result = await _getAgentMe(const NoParams());
    result.when(
      ok: (profile) {
        AppLog.line(
          '[BLOC] profile loaded id=${profile.id} name=${profile.fullName}',
        );
        emit(ProfileLoaded(profile));
      },
      err: (failure) {
        AppLog.line('[BLOC] profile load failed: ${failure.message}');
        if (previous != null) {
          emit(previous);
          return;
        }
        emit(ProfileFailure(failure.message));
      },
    );
  }
}
