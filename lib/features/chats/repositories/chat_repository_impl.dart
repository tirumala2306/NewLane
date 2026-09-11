import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/chats/data/datasources/chat_api_remote_data_source.dart';
import 'package:newlane/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    ChatApiRemoteDataSource? chatApi,
  }) : _remote = remote,
       _chatApi = chatApi;

  final ChatRemoteDataSource _remote;
  final ChatApiRemoteDataSource? _chatApi;

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
  }) async {
    await _remote.sendTextMessage(
      chatId: chatId,
      currentUserId: currentUserId,
      senderName: senderName,
      text: text,
      senderAvatar: senderAvatar,
    );

    final ChatApiRemoteDataSource? api = _chatApi;
    if (api == null) return;

    try {
      final List<String> others = await _remote.otherParticipantIds(
        chatId: chatId,
        currentUserId: currentUserId,
      );
      final List<int> recipientIds = others
          .map(int.tryParse)
          .whereType<int>()
          .toList();
      if (recipientIds.isEmpty) {
        AppLog.section('CHAT PUSH SKIPPED', <String, Object?>{
          'chatId': chatId,
          'currentUserId': currentUserId,
          'otherParticipantIds': others,
          'reason':
              'No numeric recipient user ids (peer must be a real agent id)',
        });
        return;
      }

      AppLog.line(
        '[CHAT PUSH] notify → recipients=$recipientIds chatId=$chatId',
      );
      await api.notifyMessage(
        conversationId: chatId,
        recipientUserIds: recipientIds,
        title: senderName,
        body: text,
      );
      AppLog.line('[CHAT PUSH] notify OK');
    } catch (error, stack) {
      // Message already saved — push failure must not block chat UX.
      AppLog.section('CHAT PUSH NOTIFY', <String, Object?>{
        'ERROR': error,
        'STACK': stack,
      });
    }
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
