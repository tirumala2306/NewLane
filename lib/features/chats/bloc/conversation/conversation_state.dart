import 'package:equatable/equatable.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => <Object?>[];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationReady extends ConversationState {
  const ConversationReady({
    required this.messages,
    required this.currentUserId,
    this.draft = '',
    this.isSending = false,
  });

  final List<ChatMessage> messages;
  final String currentUserId;
  final String draft;
  final bool isSending;

  bool get canSend => draft.trim().isNotEmpty && !isSending;

  @override
  List<Object?> get props =>
      <Object?>[messages, currentUserId, draft, isSending];
}

class ConversationFailure extends ConversationState {
  const ConversationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
