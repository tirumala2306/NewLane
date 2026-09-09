import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/domain/usecases/get_agent_me.dart';
import 'package:newlane/features/directory/bloc/directory_event.dart';
import 'package:newlane/features/directory/bloc/directory_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_agents.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    required GetDirectoryAgents getDirectoryAgents,
    required GetAgentMe getAgentMe,
  }) : _getDirectoryAgents = getDirectoryAgents,
       _getAgentMe = getAgentMe,
       super(const DirectoryInitial()) {
    on<DirectoryStarted>(_onStarted);
    on<DirectorySearchChanged>(_onSearchChanged);
    on<DirectoryRefreshed>(_onRefreshed);
  }

  final GetDirectoryAgents _getDirectoryAgents;
  final GetAgentMe _getAgentMe;
  String _search = '';
  String _office = '';

  Future<void> _onStarted(
    DirectoryStarted event,
    Emitter<DirectoryState> emit,
  ) {
    return _load(emit, resolveOffice: true);
  }

  Future<void> _onSearchChanged(
    DirectorySearchChanged event,
    Emitter<DirectoryState> emit,
  ) {
    _search = event.query.trim();
    return _load(emit);
  }

  Future<void> _onRefreshed(
    DirectoryRefreshed event,
    Emitter<DirectoryState> emit,
  ) {
    return _load(emit, resolveOffice: true);
  }

  Future<void> _resolveOffice() async {
    final result = await _getAgentMe(const NoParams());
    result.when(
      ok: (profile) {
        _office = profile.directoryOfficeQuery;
        AppLog.line(
          '[BLOC] directory office="$_office" name="${profile.officeName}"',
        );
      },
      err: (failure) {
        AppLog.line('[BLOC] directory office resolve failed: ${failure.message}');
      },
    );
  }

  Future<void> _load(
    Emitter<DirectoryState> emit, {
    bool resolveOffice = false,
  }) async {
    final DirectoryAgentsPage? previous = switch (state) {
      DirectoryLoaded(:final DirectoryAgentsPage page) => page,
      DirectoryLoading(:final DirectoryAgentsPage? previous) => previous,
      DirectoryFailure(:final DirectoryAgentsPage? previous) => previous,
      _ => null,
    };

    emit(DirectoryLoading(previous: previous));

    if (resolveOffice || _office.isEmpty) {
      await _resolveOffice();
    }

    AppLog.line(
      '[BLOC] directory load search="$_search" office="$_office"',
    );

    final result = await _getDirectoryAgents(
      GetDirectoryAgentsParams(
        search: _search,
        office: _office,
        sort: 'name_asc',
      ),
    );

    result.when(
      ok: (page) {
        AppLog.line('[BLOC] directory loaded agents=${page.agents.length}');
        emit(DirectoryLoaded(page));
      },
      err: (failure) {
        AppLog.line('[BLOC] directory failed: ${failure.message}');
        emit(DirectoryFailure(failure.message, previous: previous));
      },
    );
  }
}
