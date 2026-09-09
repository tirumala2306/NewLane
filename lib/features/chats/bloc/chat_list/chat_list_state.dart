import 'package:equatable/equatable.dart';
import 'package:newlane/features/chats/domain/entities/chat_filter.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';

sealed class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => <Object?>[];
}

class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  const ChatListLoaded({
    required this.threads,
    required this.filter,
    this.searchQuery = '',
  });

  final List<ChatThread> threads;
  final ChatFilter filter;
  final String searchQuery;

  List<ChatThread> get visibleThreads {
    Iterable<ChatThread> list = threads;
    switch (filter) {
      case ChatFilter.all:
        break;
      case ChatFilter.announcements:
        list = list.where((ChatThread t) => t.isAnnouncement);
      case ChatFilter.pinned:
        list = list.where((ChatThread t) => t.isPinned);
    }
    final String q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (ChatThread t) =>
            t.title.toLowerCase().contains(q) ||
            t.lastMessage.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  @override
  List<Object?> get props => <Object?>[threads, filter, searchQuery];
}

class ChatListFailure extends ChatListState {
  const ChatListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
