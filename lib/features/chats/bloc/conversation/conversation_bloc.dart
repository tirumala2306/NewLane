import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/chats/bloc/conversation/conversation_event.dart';
import 'package:newlane/features/chats/bloc/conversation/conversation_state.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ConversationInitial()) {
    on<ConversationStarted>(_onStarted);
    on<ConversationTextChanged>(_onTextChanged);
    on<ConversationSendPressed>(_onSendPressed);
    on<_ConversationMessagesUpdated>(_onMessagesUpdated);
    on<_ConversationStreamFailed>(_onStreamFailed);
  }

  final ChatRepository _chatRepository;
  StreamSubscription<List<ChatMessage>>? _subscription;

  String _chatId = '';
  String _currentUserId = '';
  String _currentUserName = '';
  String _currentUserAvatar = '';
  String _draft = '';

  Future<void> _onStarted(
    ConversationStarted event,
    Emitter<ConversationState> emit,
  ) async {
    _chatId = event.chatId;
    _currentUserId = event.currentUserId;
    _currentUserName = event.currentUserName;
    _currentUserAvatar = event.currentUserAvatar;
    _draft = '';

    emit(const ConversationLoading());

    await _chatRepository.markThreadRead(
      chatId: _chatId,
      currentUserId: _currentUserId,
    );

    await _subscription?.cancel();
    _subscription = _chatRepository
        .watchMessages(chatId: _chatId, currentUserId: _currentUserId)
        .listen(
          (List<ChatMessage> messages) {
            add(_ConversationMessagesUpdated(messages));
          },
          onError: (Object error, StackTrace stack) {
            AppLog.section('CHAT MESSAGES STREAM', <String, Object?>{
              'ERROR': error,
              'STACK': stack,
            });
            add(_ConversationStreamFailed('$error'));
          },
        );
  }

  void _onTextChanged(
    ConversationTextChanged event,
    Emitter<ConversationState> emit,
  ) {
    _draft = event.text;
    final ConversationState current = state;
    if (current is ConversationReady) {
      emit(
        ConversationReady(
          messages: current.messages,
          currentUserId: current.currentUserId,
          draft: _draft,
          isSending: current.isSending,
        ),
      );
    }
  }

  Future<void> _onSendPressed(
    ConversationSendPressed event,
    Emitter<ConversationState> emit,
  ) async {
    final ConversationState current = state;
    if (current is! ConversationReady || !current.canSend) return;

    final String text = _draft.trim();
    emit(
      ConversationReady(
        messages: current.messages,
        currentUserId: current.currentUserId,
        draft: '',
        isSending: true,
      ),
    );
    _draft = '';

    try {
      await _chatRepository.sendTextMessage(
        chatId: _chatId,
        currentUserId: _currentUserId,
        senderName: _currentUserName,
        text: text,
        senderAvatar: _currentUserAvatar,
      );
    } catch (error, stack) {
      AppLog.section('CHAT SEND FAILED', <String, Object?>{
        'ERROR': error,
        'STACK': stack,
      });
      emit(ConversationFailure('$error'));
      return;
    }

    final ConversationState after = state;
    if (after is ConversationReady) {
      emit(
        ConversationReady(
          messages: after.messages,
          currentUserId: after.currentUserId,
          draft: after.draft,
          isSending: false,
        ),
      );
    }
  }

  void _onMessagesUpdated(
    _ConversationMessagesUpdated event,
    Emitter<ConversationState> emit,
  ) {
    emit(
      ConversationReady(
        messages: event.messages,
        currentUserId: _currentUserId,
        draft: _draft,
      ),
    );
  }

  void _onStreamFailed(
    _ConversationStreamFailed event,
    Emitter<ConversationState> emit,
  ) {
    emit(ConversationFailure(event.message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class _ConversationMessagesUpdated extends ConversationEvent {
  const _ConversationMessagesUpdated(this.messages);

  final List<ChatMessage> messages;

  @override
  List<Object?> get props => <Object?>[messages];
}

class _ConversationStreamFailed extends ConversationEvent {
  const _ConversationStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
