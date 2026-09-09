import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ConversationStarted extends ConversationEvent {
  const ConversationStarted({
    required this.chatId,
    required this.currentUserId,
    required this.currentUserName,
    this.currentUserAvatar = '',
  });

  final String chatId;
  final String currentUserId;
  final String currentUserName;
  final String currentUserAvatar;

  @override
  List<Object?> get props =>
      <Object?>[chatId, currentUserId, currentUserName, currentUserAvatar];
}

class ConversationTextChanged extends ConversationEvent {
  const ConversationTextChanged(this.text);

  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

class ConversationSendPressed extends ConversationEvent {
  const ConversationSendPressed();
}
