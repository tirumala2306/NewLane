import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newlane/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';

/// Live Firestore chat backend.
///
/// Schema:
/// ```
/// chats/{chatId}
///   type, title, participantIds, lastMessage, lastMessageAt,
///   pinnedBy[], unreadCounts {uid: int}, avatarUrl, peer map...
/// chats/{chatId}/messages/{messageId}
///   text, senderId, senderName, senderAvatar, createdAt, readBy[]
/// ```
class FirestoreChatRemoteDataSource implements ChatRemoteDataSource {
  FirestoreChatRemoteDataSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  @override
  Stream<List<ChatThread>> watchThreads({required String currentUserId}) {
    return _chats
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
          return snap.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();
            final String typeRaw = (data['type'] as String?) ?? 'direct';
            final List<dynamic> pinnedBy =
                (data['pinnedBy'] as List<dynamic>?) ?? <dynamic>[];
            final Map<String, dynamic> unread =
                (data['unreadCounts'] as Map<String, dynamic>?) ??
                <String, dynamic>{};
            final Timestamp? ts = data['lastMessageAt'] as Timestamp?;

            return ChatThread(
              id: doc.id,
              type: typeRaw == 'announcement'
                  ? ChatThreadType.announcement
                  : ChatThreadType.direct,
              title: (data['title'] as String?) ?? 'Chat',
              lastMessage: (data['lastMessage'] as String?) ?? '',
              lastMessageAt: ts?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
              unreadCount: (unread[currentUserId] as num?)?.toInt() ?? 0,
              isPinned: pinnedBy.contains(currentUserId),
              avatarUrl: (data['avatarUrl'] as String?) ?? '',
              isOnline: data['isOnline'] == true,
              peerUserId: (data['peerUserId'] as String?) ?? '',
            );
          }).toList();
        });
  }

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    required String currentUserId,
  }) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
          return snap.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();
            final Timestamp? ts = data['createdAt'] as Timestamp?;
            final List<dynamic> readBy =
                (data['readBy'] as List<dynamic>?) ?? <dynamic>[];
            return ChatMessage(
              id: doc.id,
              chatId: chatId,
              text: (data['text'] as String?) ?? '',
              senderId: (data['senderId'] as String?) ?? '',
              senderName: (data['senderName'] as String?) ?? '',
              senderAvatar: (data['senderAvatar'] as String?) ?? '',
              createdAt: ts?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
              isRead: readBy.contains(currentUserId) ||
                  (data['senderId'] as String?) == currentUserId,
            );
          }).toList();
        });
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

    final DocumentReference<Map<String, dynamic>> chatRef = _chats.doc(chatId);
    final DocumentSnapshot<Map<String, dynamic>> chatSnap = await chatRef.get();
    final Map<String, dynamic> chatData =
        chatSnap.data() ?? <String, dynamic>{};
    final List<dynamic> participants =
        (chatData['participantIds'] as List<dynamic>?) ?? <dynamic>[];

    final WriteBatch batch = _db.batch();
    final DocumentReference<Map<String, dynamic>> messageRef =
        chatRef.collection('messages').doc();

    batch.set(messageRef, <String, dynamic>{
      'text': trimmed,
      'senderId': currentUserId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': <String>[currentUserId],
    });

    final Map<String, dynamic> unreadUpdates = <String, dynamic>{
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUserId,
    };

    for (final dynamic rawId in participants) {
      final String uid = rawId.toString();
      if (uid == currentUserId) {
        unreadUpdates['unreadCounts.$uid'] = 0;
      } else {
        unreadUpdates['unreadCounts.$uid'] = FieldValue.increment(1);
      }
    }

    batch.update(chatRef, unreadUpdates);
    await batch.commit();
  }

  @override
  Future<void> markThreadRead({
    required String chatId,
    required String currentUserId,
  }) async {
    await _chats.doc(chatId).update(<String, dynamic>{
      'unreadCounts.$currentUserId': 0,
    });
  }
}
