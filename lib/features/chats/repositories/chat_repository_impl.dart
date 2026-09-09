import 'package:newlane/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remote}) : _remote = remote;

  final ChatRemoteDataSource _remote;

  @override
  Stream<List<ChatThread>> watchThreads({required String currentUserId}) {
    return _remote.watchThreads(currentUserId: currentUserId);
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    required String currentUserId,
  }) {
    return _remote.watchMessages(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<void> sendTextMessage({
    required String chatId,
    required String currentUserId,
    required String senderName,
    required String text,
    String senderAvatar = '',
  }) {
    return _remote.sendTextMessage(
      chatId: chatId,
      currentUserId: currentUserId,
      senderName: senderName,
      text: text,
      senderAvatar: senderAvatar,
    );
  }

  @override
  Future<void> markThreadRead({
    required String chatId,
    required String currentUserId,
  }) {
    return _remote.markThreadRead(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<String> ensureDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String peerUserId,
    required String peerName,
    String peerAvatar = '',
    String currentUserAvatar = '',
  }) {
    return _remote.ensureDirectChat(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      peerUserId: peerUserId,
      peerName: peerName,
      peerAvatar: peerAvatar,
      currentUserAvatar: currentUserAvatar,
    );
  }
}
