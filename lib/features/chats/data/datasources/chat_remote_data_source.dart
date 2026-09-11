import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';

/// Remote chat API — Firestore or in-memory mock.
///
/// Both implementations expose **streams** so the UI auto-updates
/// the same way Firestore `snapshots()` does.
abstract class ChatRemoteDataSource {
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

  /// Other participant user ids for push (excludes [currentUserId]).
  Future<List<String>> otherParticipantIds({
    required String chatId,
    required String currentUserId,
  });

  Future<void> markThreadRead({
    required String chatId,
    required String currentUserId,
  });

  /// Creates the DM thread if missing; returns chat document id.
  Future<String> ensureDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String peerUserId,
    required String peerName,
    String peerAvatar,
    String currentUserAvatar,
  });
}
