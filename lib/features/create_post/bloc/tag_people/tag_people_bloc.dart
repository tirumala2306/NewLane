import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/create_post/bloc/tag_people/tag_people_event.dart';
import 'package:newlane/features/create_post/bloc/tag_people/tag_people_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_agents.dart';

class TagPeopleBloc extends Bloc<TagPeopleEvent, TagPeopleState> {
  TagPeopleBloc({required GetDirectoryAgents getDirectoryAgents})
    : _getDirectoryAgents = getDirectoryAgents,
      super(const TagPeopleInitial()) {
    on<TagPeopleStarted>(_onStarted);
    on<TagPeopleSearchChanged>(_onSearchChanged);
    on<TagPeopleToggled>(_onToggled);
  }

  final GetDirectoryAgents _getDirectoryAgents;
  String _query = '';
  Set<int> _selectedIds = <int>{};
  List<DirectoryAgent> _agents = const <DirectoryAgent>[];

  Future<void> _onStarted(
    TagPeopleStarted event,
    Emitter<TagPeopleState> emit,
  ) async {
    _selectedIds = event.selectedIds.toSet();
    await _load(emit);
  }

  Future<void> _onSearchChanged(
    TagPeopleSearchChanged event,
    Emitter<TagPeopleState> emit,
  ) async {
    _query = event.query.trim();
    await _load(emit);
  }

  void _onToggled(TagPeopleToggled event, Emitter<TagPeopleState> emit) {
    final Set<int> next = Set<int>.from(_selectedIds);
    if (next.contains(event.agentId)) {
      next.remove(event.agentId);
    } else {
      next.add(event.agentId);
    }
    _selectedIds = next;
    emit(
      TagPeopleLoaded(
        agents: _agents,
        query: _query,
        selectedIds: _selectedIds,
      ),
    );
  }

  Future<void> _load(Emitter<TagPeopleState> emit) async {
    emit(
      TagPeopleLoading(
        previousAgents: _agents.isEmpty ? null : _agents,
        selectedIds: _selectedIds,
      ),
    );

    final result = await _getDirectoryAgents(
      GetDirectoryAgentsParams(search: _query),
    );
    result.when(
      ok: (DirectoryAgentsPage page) {
        _agents = page.agents;
        emit(
          TagPeopleLoaded(
            agents: page.agents,
            query: _query,
            selectedIds: _selectedIds,
          ),
        );
      },
      err: (failure) {
        emit(
          TagPeopleFailure(
            message: failure.message,
            previousAgents: _agents.isEmpty ? null : _agents,
            selectedIds: _selectedIds,
          ),
        );
      },
    );
  }
}
