import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newlane/core/utils/media_url.dart';
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
    // arrayContains + orderBy needs a composite index. Sort in-app so chat
    // works before/without that index (create it in Console when ready).
    return _chats
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
          final List<ChatThread> threads = snap.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            final String typeRaw = (data['type'] as String?) ?? 'direct';
            final List<dynamic> pinnedBy =
                (data['pinnedBy'] as List<dynamic>?) ?? <dynamic>[];
            final Map<String, dynamic> unread =
                (data['unreadCounts'] as Map<String, dynamic>?) ??
                <String, dynamic>{};
            final Timestamp? ts = data['lastMessageAt'] as Timestamp?;
            final List<dynamic> participants =
                (data['participantIds'] as List<dynamic>?) ?? <dynamic>[];
            final Map<String, dynamic> peerNames =
                (data['peerNames'] as Map<String, dynamic>?) ??
                <String, dynamic>{};
            final Map<String, dynamic> peerAvatars =
                (data['peerAvatars'] as Map<String, dynamic>?) ??
                <String, dynamic>{};

            String title = (data['title'] as String?) ?? 'Chat';
            String avatarUrl = (data['avatarUrl'] as String?) ?? '';
            String peerUserId = (data['peerUserId'] as String?) ?? '';

            // Always show the *other* person's name/photo for DMs.
            if (typeRaw != 'announcement') {
              String? otherId;
              for (final dynamic raw in participants) {
                final String id = raw.toString();
                if (id.isNotEmpty && id != currentUserId) {
                  otherId = id;
                  break;
                }
              }
              if (otherId != null) {
                peerUserId = otherId;
                final String named = peerNames[otherId]?.toString() ?? '';
                final String av = peerAvatars[otherId]?.toString() ?? '';
                if (named.trim().isNotEmpty) title = named.trim();
                if (av.trim().isNotEmpty) avatarUrl = av.trim();
              }
            }

            return ChatThread(
              id: doc.id,
              type: typeRaw == 'announcement'
                  ? ChatThreadType.announcement
                  : ChatThreadType.direct,
              title: title,
              lastMessage: (data['lastMessage'] as String?) ?? '',
              lastMessageAt:
                  ts?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
              unreadCount: (unread[currentUserId] as num?)?.toInt() ?? 0,
              isPinned: pinnedBy.contains(currentUserId),
              avatarUrl: avatarUrl,
              isOnline: false,
              peerUserId: peerUserId,
            );
          }).toList()

          ..sort(
            (ChatThread a, ChatThread b) =>
                b.lastMessageAt.compareTo(a.lastMessageAt),
          );
          return threads;
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
      'senderAvatar': resolveMediaUrl(senderAvatar) ?? senderAvatar,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': <String>[currentUserId],
    });

    final String resolvedSenderAvatar =
        resolveMediaUrl(senderAvatar) ?? senderAvatar;

    final Map<String, dynamic> unreadUpdates = <String, dynamic>{
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUserId,
      // Keep peer directory fresh so the other user always sees correct name/photo.
      'peerNames.$currentUserId': senderName,
      'peerAvatars.$currentUserId': resolvedSenderAvatar,
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
  Future<List<String>> otherParticipantIds({
    required String chatId,
    required String currentUserId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> chatSnap =
        await _chats.doc(chatId).get();
    final Map<String, dynamic> chatData =
        chatSnap.data() ?? <String, dynamic>{};
    final List<dynamic> participants =
        (chatData['participantIds'] as List<dynamic>?) ?? <dynamic>[];
    final Set<String> ids = participants
        .map((dynamic id) => id.toString())
        .where((String id) => id.isNotEmpty && id != currentUserId)
        .toSet();

    final String peer =
        (chatData['peerUserId'] as String?)?.trim() ?? '';
    if (peer.isNotEmpty && peer != currentUserId) {
      ids.add(peer);
    }

    return ids.toList();
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

  @override
  Future<String> ensureDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String peerUserId,
    required String peerName,
    String peerAvatar = '',
    String currentUserAvatar = '',
  }) async {
    final List<String> pair = <String>[currentUserId, peerUserId]..sort();
    final String chatId = 'dm_${pair.join('_')}';
    final DocumentReference<Map<String, dynamic>> chatRef = _chats.doc(chatId);
    final DocumentSnapshot<Map<String, dynamic>> existing = await chatRef.get();

    final String resolvedPeerAvatar = resolveMediaUrl(peerAvatar) ?? peerAvatar;
    final String resolvedMyAvatar =
        resolveMediaUrl(currentUserAvatar) ?? currentUserAvatar;

    if (existing.exists) {
      // Refresh both sides' names/avatars (do not use single title for both users).
      await chatRef.set(<String, dynamic>{
        'peerNames': <String, String>{
          currentUserId: currentUserName,
          peerUserId: peerName,
        },
        'peerAvatars': <String, String>{
          currentUserId: resolvedMyAvatar,
          peerUserId: resolvedPeerAvatar,
        },
        'isOnline': false,
      }, SetOptions(merge: true));
      return chatId;
    }

    await chatRef.set(<String, dynamic>{
      'type': 'direct',
      'title': peerName,
      'participantIds': <String>[currentUserId, peerUserId],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': '',
      'pinnedBy': <String>[],
      'unreadCounts': <String, int>{
        currentUserId: 0,
        peerUserId: 0,
      },
      'avatarUrl': resolvedPeerAvatar,
      'peerUserId': peerUserId,
      'peerNames': <String, String>{
        currentUserId: currentUserName,
        peerUserId: peerName,
      },
      'peerAvatars': <String, String>{
        currentUserId: resolvedMyAvatar,
        peerUserId: resolvedPeerAvatar,
      },
      'isOnline': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatId;
  }
}
