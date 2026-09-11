import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/domain/usecases/get_agent_me.dart';
import 'package:newlane/features/directory/bloc/office_directory_event.dart';
import 'package:newlane/features/directory/bloc/office_directory_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_team.dart';

class OfficeDirectoryBloc
    extends Bloc<OfficeDirectoryEvent, OfficeDirectoryState> {
  OfficeDirectoryBloc({
    required GetDirectoryTeam getDirectoryTeam,
    required GetAgentMe getAgentMe,
  }) : _getDirectoryTeam = getDirectoryTeam,
       _getAgentMe = getAgentMe,
       super(const OfficeDirectoryInitial()) {
    on<OfficeDirectoryStarted>(_onStarted);
    on<OfficeDirectorySearchChanged>(_onSearchChanged);
    on<OfficeDirectoryDepartmentChanged>(_onDepartmentChanged);
    on<OfficeDirectoryRefreshed>(_onRefreshed);
  }

  static const String defaultDepartment = 'All';

  final GetDirectoryTeam _getDirectoryTeam;
  final GetAgentMe _getAgentMe;
  String _search = '';
  String _department = defaultDepartment;
  String _officeName = '';
  int _currentUserId = 0;

  Future<void> _onStarted(
    OfficeDirectoryStarted event,
    Emitter<OfficeDirectoryState> emit,
  ) {
    return _load(emit, resolveOffice: true);
  }

  Future<void> _onSearchChanged(
    OfficeDirectorySearchChanged event,
    Emitter<OfficeDirectoryState> emit,
  ) {
    _search = event.query.trim();
    return _load(emit);
  }

  Future<void> _onDepartmentChanged(
    OfficeDirectoryDepartmentChanged event,
    Emitter<OfficeDirectoryState> emit,
  ) {
    final String next = event.department.trim().isEmpty
        ? defaultDepartment
        : event.department.trim();
    if (next == _department) return Future<void>.value();
    _department = next;
    return _load(emit);
  }

  Future<void> _onRefreshed(
    OfficeDirectoryRefreshed event,
    Emitter<OfficeDirectoryState> emit,
  ) {
    return _load(emit, resolveOffice: true);
  }

  Future<void> _resolveOfficeName() async {
    final result = await _getAgentMe(const NoParams());
    result.when(
      ok: (profile) {
        _officeName = profile.officeName.trim();
        _currentUserId = profile.id;
        AppLog.line(
          '[BLOC] office directory office="$_officeName" me=$_currentUserId',
        );
      },
      err: (failure) {
        AppLog.line(
          '[BLOC] office directory office resolve failed: ${failure.message}',
        );
      },
    );
  }

  Future<void> _load(
    Emitter<OfficeDirectoryState> emit, {
    bool resolveOffice = false,
  }) async {
    final DirectoryAgentsPage? previous = switch (state) {
      OfficeDirectoryLoaded(:final DirectoryAgentsPage page) => page,
      OfficeDirectoryLoading(:final DirectoryAgentsPage? previous) => previous,
      OfficeDirectoryFailure(:final DirectoryAgentsPage? previous) => previous,
      _ => null,
    };

    emit(
      OfficeDirectoryLoading(
        previous: previous,
        department: _department,
        officeName: _officeName,
      ),
    );

    if (resolveOffice || _officeName.isEmpty || _currentUserId <= 0) {
      await _resolveOfficeName();
    }

    AppLog.line(
      '[BLOC] office directory load search="$_search" department="$_department"',
    );

    final result = await _getDirectoryTeam(
      GetDirectoryTeamParams(search: _search, department: _department),
    );

    result.when(
      ok: (page) {
        final List<DirectoryAgent> others = page.agents
            .where((DirectoryAgent a) => a.id != _currentUserId)
            .toList();
        final DirectoryAgentsPage filtered = DirectoryAgentsPage(
          agents: others,
          total: others.length,
          page: page.page,
          pages: page.pages,
        );
        AppLog.line(
          '[BLOC] office directory loaded members=${others.length} (excluded me)',
        );
        emit(
          OfficeDirectoryLoaded(
            page: filtered,
            department: _department,
            officeName: _officeName,
          ),
        );
      },
      err: (failure) {
        AppLog.line('[BLOC] office directory failed: ${failure.message}');
        emit(
          OfficeDirectoryFailure(
            failure.message,
            previous: previous,
            department: _department,
            officeName: _officeName,
          ),
        );
      },
    );
  }
}
