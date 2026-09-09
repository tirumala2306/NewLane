import 'package:equatable/equatable.dart';
import 'package:newlane/features/chats/domain/entities/chat_filter.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ChatListStarted extends ChatListEvent {
  const ChatListStarted({required this.currentUserId});

  final String currentUserId;

  @override
  List<Object?> get props => <Object?>[currentUserId];
}

class ChatListFilterChanged extends ChatListEvent {
  const ChatListFilterChanged(this.filter);

  final ChatFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

class ChatListSearchChanged extends ChatListEvent {
  const ChatListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}
