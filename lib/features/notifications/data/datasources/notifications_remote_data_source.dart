import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/notifications/data/models/app_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getMine({int? currentUserId});
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<AppNotificationModel>> getMine({int? currentUserId}) async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.notificationsMine}');
    final response = await _apiClient.get<dynamic>(ApiEndpoints.notificationsMine);
    final ApiEnvelope envelope = ApiEnvelope.from(response.data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Failed to load notifications' : envelope.message,
        statusCode: response.statusCode,
      );
    }
    return parseNotificationsList(envelope.data, currentUserId: currentUserId);
  }
}
