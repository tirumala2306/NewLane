import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/notifications/data/push_notification_prefs.dart';

abstract class DevicesRemoteDataSource {
  Future<void> registerToken({
    required String token,
    required String platform,
  });

  Future<void> unregisterToken({required String token});

  Future<void> syncPrefs(PushNotificationPrefs prefs);
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  DevicesRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _client.post<dynamic>(
        ApiEndpoints.devices,
        data: <String, dynamic>{
          'token': token,
          'platform': platform,
        },
      );
      AppLog.line('[PUSH] token registered with backend');
    } on DioException catch (error) {
      // Backend may not be ready yet — don't crash the app.
      AppLog.line('[PUSH] register token failed: ${error.message}');
      rethrow;
    } catch (error) {
      AppLog.line('[PUSH] register token failed: $error');
      rethrow;
    }
  }

  @override
  Future<void> unregisterToken({required String token}) async {
    try {
      await _client.delete<dynamic>(
        ApiEndpoints.devices,
        data: <String, dynamic>{'token': token},
      );
      AppLog.line('[PUSH] token unregistered');
    } catch (error) {
      AppLog.line('[PUSH] unregister token failed: $error');
    }
  }

  @override
  Future<void> syncPrefs(PushNotificationPrefs prefs) async {
    try {
      await _client.put<dynamic>(
        ApiEndpoints.notificationPrefs,
        data: prefs.toJson(),
      );
      AppLog.line('[PUSH] prefs synced');
    } catch (error) {
      if (kDebugMode) {
        AppLog.line('[PUSH] prefs sync skipped/failed: $error');
      }
    }
  }
}
