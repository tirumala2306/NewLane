import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';

abstract class ChatRepository {
  Stream<List<ChatThread>> watchThreads({required String currentUserId});

  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    required String currentUserId,
  });

  Future<void> sendTextMessage({
    required String chatId,
    required String currentUserId,
    required String senderName,
    required String text,
    String senderAvatar,
  });

  Future<void> markThreadRead({
    required String chatId,
    required String currentUserId,
  });
}
