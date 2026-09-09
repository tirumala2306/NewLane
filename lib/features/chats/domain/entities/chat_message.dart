/// A single text message inside a chat thread.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.senderAvatar = '',
    this.isRead = false,
  });

  final String id;
  final String chatId;
  final String text;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final DateTime createdAt;
  final bool isRead;

  bool isMine(String currentUserId) => senderId == currentUserId;
}
