import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/chats/bloc/chat_list/chat_list_event.dart';
import 'package:newlane/features/chats/bloc/chat_list/chat_list_state.dart';
import 'package:newlane/features/chats/domain/entities/chat_filter.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';

/// Listens to [ChatRepository.watchThreads] (Firestore or mock stream).
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatListInitial()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListFilterChanged>(_onFilterChanged);
    on<ChatListSearchChanged>(_onSearchChanged);
    on<_ChatListThreadsUpdated>(_onThreadsUpdated);
    on<_ChatListStreamFailed>(_onStreamFailed);
  }

  final ChatRepository _chatRepository;
  StreamSubscription<List<ChatThread>>? _subscription;
  ChatFilter _filter = ChatFilter.all;
  String _search = '';

  Future<void> _onStarted(
    ChatListStarted event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _subscription?.cancel();
    _subscription = _chatRepository
        .watchThreads(currentUserId: event.currentUserId)
        .listen(
          (List<ChatThread> threads) {
            add(_ChatListThreadsUpdated(threads));
          },
          onError: (Object error, StackTrace stack) {
            AppLog.section('CHAT LIST STREAM', <String, Object?>{
              'ERROR': error,
              'STACK': stack,
            });
            add(_ChatListStreamFailed('$error'));
          },
        );
  }

  void _onFilterChanged(
    ChatListFilterChanged event,
    Emitter<ChatListState> emit,
  ) {
    _filter = event.filter;
    final ChatListState current = state;
    if (current is ChatListLoaded) {
      emit(
        ChatListLoaded(
          threads: current.threads,
          filter: _filter,
          searchQuery: _search,
        ),
      );
    }
  }

  void _onSearchChanged(
    ChatListSearchChanged event,
    Emitter<ChatListState> emit,
  ) {
    _search = event.query;
    final ChatListState current = state;
    if (current is ChatListLoaded) {
      emit(
        ChatListLoaded(
          threads: current.threads,
          filter: _filter,
          searchQuery: _search,
        ),
      );
    }
  }

  void _onThreadsUpdated(
    _ChatListThreadsUpdated event,
    Emitter<ChatListState> emit,
  ) {
    emit(
      ChatListLoaded(
        threads: event.threads,
        filter: _filter,
        searchQuery: _search,
      ),
    );
  }

  void _onStreamFailed(
    _ChatListStreamFailed event,
    Emitter<ChatListState> emit,
  ) {
    emit(ChatListFailure(event.message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class _ChatListThreadsUpdated extends ChatListEvent {
  const _ChatListThreadsUpdated(this.threads);

  final List<ChatThread> threads;

  @override
  List<Object?> get props => <Object?>[threads];
}

class _ChatListStreamFailed extends ChatListEvent {
  const _ChatListStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
