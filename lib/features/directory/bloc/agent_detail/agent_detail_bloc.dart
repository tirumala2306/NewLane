import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/domain/usecases/get_agent_me.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_event.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/domain/usecases/get_directory_agent_by_id.dart';

class AgentDetailBloc extends Bloc<AgentDetailEvent, AgentDetailState> {
  AgentDetailBloc({
    required GetDirectoryAgentById getDirectoryAgentById,
    required GetAgentMe getAgentMe,
    required ChatRepository chatRepository,
  }) : _getDirectoryAgentById = getDirectoryAgentById,
       _getAgentMe = getAgentMe,
       _chatRepository = chatRepository,
       super(const AgentDetailInitial()) {
    on<AgentDetailStarted>(_onStarted);
    on<AgentDetailMessagePressed>(_onMessagePressed);
  }

  final GetDirectoryAgentById _getDirectoryAgentById;
  final GetAgentMe _getAgentMe;
  final ChatRepository _chatRepository;

  DirectoryAgent? _agent;
  AgentProfile? _me;

  Future<void> _onStarted(
    AgentDetailStarted event,
    Emitter<AgentDetailState> emit,
  ) async {
    _agent = event.initial;
    emit(AgentDetailLoading(agent: _agent));

    final meResult = await _getAgentMe(const NoParams());
    meResult.when(
      ok: (AgentProfile profile) => _me = profile,
      err: (_) {},
    );

    final result = await _getDirectoryAgentById(
      GetDirectoryAgentByIdParams(event.agentId),
    );
    result.when(
      ok: (DirectoryAgent agent) {
        _agent = agent;
        emit(AgentDetailLoaded(agent));
      },
      err: (failure) {
        if (_agent != null) {
          emit(AgentDetailLoaded(_agent!));
          AppLog.line(
            '[BLOC] agent detail fetch failed, using list data: ${failure.message}',
          );
        } else {
          emit(AgentDetailFailure(failure.message));
        }
      },
    );
  }

  Future<void> _onMessagePressed(
    AgentDetailMessagePressed event,
    Emitter<AgentDetailState> emit,
  ) async {
    final DirectoryAgent? agent = _agent;
    if (agent == null) return;

    final AgentProfile? me = _me;
    if (me == null) {
      emit(AgentDetailFailure('Could not load your profile.', agent: agent));
      return;
    }

    if (me.id == agent.id) {
      emit(
        AgentDetailFailure('You cannot message yourself.', agent: agent),
      );
      return;
    }

    emit(AgentDetailLoaded(agent, isStartingChat: true));

    try {
      final String chatId = await _chatRepository.ensureDirectChat(
        currentUserId: '${me.id}',
        currentUserName: me.fullName,
        currentUserAvatar: me.avatar,
        peerUserId: '${agent.id}',
        peerName: agent.fullName,
        peerAvatar: agent.avatar,
      );
      emit(AgentDetailChatReady(agent: agent, chatId: chatId));
      emit(AgentDetailLoaded(agent));
    } catch (error, stack) {
      AppLog.section('START DM FAILED', <String, Object?>{
        'ERROR': error,
        'STACK': stack,
      });
      emit(AgentDetailFailure('$error', agent: agent));
    }
  }
}
