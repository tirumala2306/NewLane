import 'dart:async';

import 'package:newlane/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';

/// Local stand-in for Firestore until `flutterfire configure` is done.
///
/// Uses [StreamController.broadcast] so multiple screens can listen —
/// same idea as Firestore `snapshots()`.
class MockChatRemoteDataSource implements ChatRemoteDataSource {
  MockChatRemoteDataSource() {
    _seed();
  }

  final List<ChatThread> _threads = <ChatThread>[];
  final Map<String, List<ChatMessage>> _messagesByChat =
      <String, List<ChatMessage>>{};

  final StreamController<List<ChatThread>> _threadsController =
      StreamController<List<ChatThread>>.broadcast();

  final Map<String, StreamController<List<ChatMessage>>> _messageControllers =
      <String, StreamController<List<ChatMessage>>>{};

  int _idCounter = 100;

  void _seed() {
    final DateTime now = DateTime.now();

    _threads.addAll(<ChatThread>[
      ChatThread(
        id: 'announcement_office',
        type: ChatThreadType.announcement,
        title: 'Office Announcement',
        lastMessage: 'Team meeting this Friday at 10:00 AM',
        lastMessageAt: DateTime(now.year, now.month, now.day, 10),
        unreadCount: 1,
        isPinned: true,
      ),
      ChatThread(
        id: 'dm_sarah',
        type: ChatThreadType.direct,
        title: 'Sarah Johnson',
        lastMessage: 'Perfect, see you all there!',
        lastMessageAt: DateTime(now.year, now.month, now.day, 9, 41),
        unreadCount: 1,
        isPinned: false,
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        isOnline: true,
        peerUserId: 'user_sarah',
      ),
      ChatThread(
        id: 'dm_sarah_2',
        type: ChatThreadType.direct,
        title: 'Sarah Johnson',
        lastMessage: 'Perfect, see you all there!',
        lastMessageAt: DateTime(now.year, now.month, now.day, 9, 41),
        unreadCount: 1,
        isPinned: false,
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        isOnline: true,
        peerUserId: 'user_sarah_2',
      ),
      ChatThread(
        id: 'dm_sarah_3',
        type: ChatThreadType.direct,
        title: 'Sarah Johnson',
        lastMessage: 'Perfect, see you all there!',
        lastMessageAt: DateTime(now.year, now.month, now.day, 9, 41),
        unreadCount: 1,
        isPinned: false,
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        isOnline: false,
        peerUserId: 'user_sarah_3',
      ),
    ]);

    _messagesByChat['announcement_office'] = <ChatMessage>[
      ChatMessage(
        id: 'm1',
        chatId: 'announcement_office',
        text: 'Team meeting this Friday at 10:00 AM',
        senderId: 'office_admin',
        senderName: 'Office Admin',
        createdAt: DateTime(now.year, now.month, now.day, 10),
      ),
    ];

    _messagesByChat['dm_sarah'] = <ChatMessage>[
      ChatMessage(
        id: 'm2',
        chatId: 'dm_sarah',
        text: "Don't forget about the team meeting this Friday at 10 AM!",
        senderId: 'user_sarah',
        senderName: 'Sarah Johnson',
        senderAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        createdAt: DateTime(now.year, now.month, now.day, 9, 41),
      ),
      ChatMessage(
        id: 'm3',
        chatId: 'dm_sarah',
        text: "I'll be there!",
        senderId: 'me',
        senderName: 'You',
        createdAt: DateTime(now.year, now.month, now.day, 9, 42),
        isRead: true,
      ),
      ChatMessage(
        id: 'm4',
        chatId: 'dm_sarah',
        text: 'Perfect, see you all there!',
        senderId: 'user_sarah',
        senderName: 'Sarah Johnson',
        senderAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        createdAt: DateTime(now.year, now.month, now.day, 9, 43),
      ),
    ];

    // Copy seed DMs for design placeholders.
    for (final String id in <String>['dm_sarah_2', 'dm_sarah_3']) {
      _messagesByChat[id] = List<ChatMessage>.from(
        (_messagesByChat['dm_sarah'] ?? <ChatMessage>[]).map(
          (ChatMessage m) => ChatMessage(
            id: '${m.id}_$id',
            chatId: id,
            text: m.text,
            senderId: m.senderId == 'user_sarah' ? 'user_$id' : m.senderId,
            senderName: m.senderName,
            senderAvatar: m.senderAvatar,
            createdAt: m.createdAt,
            isRead: m.isRead,
          ),
        ),
      );
    }

    _emitThreads();
  }

  void _emitThreads() {
    final List<ChatThread> sorted = List<ChatThread>.from(_threads)
      ..sort(
        (ChatThread a, ChatThread b) =>
            b.lastMessageAt.compareTo(a.lastMessageAt),
      );
    if (!_threadsController.isClosed) {
      _threadsController.add(sorted);
    }
  }

  void _emitMessages(String chatId) {
    final StreamController<List<ChatMessage>>? controller =
        _messageControllers[chatId];
    if (controller == null || controller.isClosed) return;
    final List<ChatMessage> list =
        List<ChatMessage>.from(_messagesByChat[chatId] ?? <ChatMessage>[])
          ..sort(
            (ChatMessage a, ChatMessage b) =>
                a.createdAt.compareTo(b.createdAt),
          );
    controller.add(list);
  }

  @override
  Stream<List<ChatThread>> watchThreads({required String currentUserId}) {
    // Late subscribers still get the current snapshot (Firestore-like).
    scheduleMicrotask(_emitThreads);
    return _threadsController.stream;
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    required String currentUserId,
  }) {
    final StreamController<List<ChatMessage>> controller =
        _messageControllers.putIfAbsent(
          chatId,
          () => StreamController<List<ChatMessage>>.broadcast(),
        );
    scheduleMicrotask(() => _emitMessages(chatId));
    return controller.stream;
  }

  @override
  Future<void> sendTextMessage({
    required String chatId,
    required String currentUserId,
    required String senderName,
    required String text,
    String senderAvatar = '',
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final String messageId = 'local_${_idCounter++}';
    final DateTime now = DateTime.now();
    final ChatMessage message = ChatMessage(
      id: messageId,
      chatId: chatId,
      text: trimmed,
      senderId: currentUserId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      createdAt: now,
      isRead: false,
    );

    final List<ChatMessage> _ =
        _messagesByChat.putIfAbsent(chatId, () => <ChatMessage>[])
    ..add(message);
    _emitMessages(chatId);

    final int index = _threads.indexWhere((ChatThread t) => t.id == chatId);
    if (index >= 0) {
      final ChatThread old = _threads[index];
      _threads[index] = ChatThread(
        id: old.id,
        type: old.type,
        title: old.title,
        lastMessage: trimmed,
        lastMessageAt: now,
        unreadCount: 0,
        isPinned: old.isPinned,
        avatarUrl: old.avatarUrl,
        isOnline: old.isOnline,
        peerUserId: old.peerUserId,
      );
      _emitThreads();
    }
  }

  @override
  Future<void> markThreadRead({
    required String chatId,
    required String currentUserId,
  }) async {
    final int index = _threads.indexWhere((ChatThread t) => t.id == chatId);
    if (index < 0) return;
    final ChatThread old = _threads[index];
    if (old.unreadCount == 0) return;
    _threads[index] = ChatThread(
      id: old.id,
      type: old.type,
      title: old.title,
      lastMessage: old.lastMessage,
      lastMessageAt: old.lastMessageAt,
      unreadCount: 0,
      isPinned: old.isPinned,
      avatarUrl: old.avatarUrl,
      isOnline: old.isOnline,
      peerUserId: old.peerUserId,
    );
    _emitThreads();
  }

  void dispose() {
    _threadsController.close();
    for (final StreamController<List<ChatMessage>> c
        in _messageControllers.values) {
      c.close();
    }
  }
}
