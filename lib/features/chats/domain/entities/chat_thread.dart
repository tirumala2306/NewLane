enum ChatThreadType { direct, announcement }

/// One row in the office chat list (DM or announcement channel).
class ChatThread {
  const ChatThread({
    required this.id,
    required this.type,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isPinned,
    this.avatarUrl = '',
    this.isOnline = false,
    this.peerUserId = '',
  });

  final String id;
  final ChatThreadType type;
  final String title;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isPinned;
  final String avatarUrl;
  final bool isOnline;

  /// Other participant id for DMs (empty for announcements).
  final String peerUserId;

  bool get isAnnouncement => type == ChatThreadType.announcement;
  bool get hasUnread => unreadCount > 0;
}
