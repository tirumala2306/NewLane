import 'package:dio/dio.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';

/// Calls Node `/api/chat/*` (Firebase Admin on the server).
class ChatApiRemoteDataSource {
  ChatApiRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<String> ensureDirectMessage({
    required String peerUserId,
    required String peerName,
    String peerAvatar = '',
  }) async {
    final Response<dynamic> response = await _apiClient.post<dynamic>(
      ApiEndpoints.chatDms,
      data: <String, dynamic>{
        'peerUserId': peerUserId,
        'peerName': peerName,
        'peerAvatar': peerAvatar,
      },
    );
    return _chatIdFrom(response.data);
  }

  Future<Map<String, dynamic>> seedDemo({required String currentUserId}) async {
    final Response<dynamic> response = await _apiClient.post<dynamic>(
      ApiEndpoints.chatSeedDemo,
      data: <String, dynamic>{'currentUserId': currentUserId},
    );
    final Object? data = response.data;
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return <String, dynamic>{};
  }

  Future<String> createAnnouncement({
    required List<String> participantIds,
    String title = 'Office Announcement',
    String message = '',
    String? officeId,
  }) async {
    final Response<dynamic> response = await _apiClient.post<dynamic>(
      ApiEndpoints.chatAnnouncements,
      data: <String, dynamic>{
        'participantIds': participantIds,
        'title': title,
        'message': message,
        'officeId': ?officeId,
      },
    );
    return _chatIdFrom(response.data);
  }

  /// Ask Node to FCM-push recipients after a Firestore message write.
  Future<void> notifyMessage({
    required String conversationId,
    required List<int> recipientUserIds,
    required String title,
    required String body,
  }) async {
    if (recipientUserIds.isEmpty || body.trim().isEmpty) return;
    await _apiClient.post<dynamic>(
      ApiEndpoints.chatNotifyMessage,
      data: <String, dynamic>{
        'conversationId': conversationId,
        'recipientUserIds': recipientUserIds,
        'title': title,
        'body': body,
      },
    );
  }

  String _chatIdFrom(Object? data) {
    if (data is Map && data['data'] is Map) {
      final Object? id = (data['data'] as Map)['chatId'];
      if (id != null) return id.toString();
    }
    return '';
  }
}
