import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:newlane/features/notifications/domain/entities/app_notification.dart';
import 'package:newlane/features/notifications/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({required NotificationsRemoteDataSource remote})
      : _remote = remote;

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Result<List<AppNotification>>> getMine({int? currentUserId}) async {
    try {
      final models = await _remote.getMine(currentUserId: currentUserId);
      final List<AppNotification> items =
          models.map((m) => m.toEntity()).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Ok<List<AppNotification>>(items);
    } on ServerException catch (e) {
      return Err<List<AppNotification>>(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      return Err<List<AppNotification>>(NetworkFailure(e.message));
    } catch (e) {
      AppLog.line('[NOTIF REPO] $e');
      return const Err<List<AppNotification>>(
        UnknownFailure('Could not load notifications.'),
      );
    }
  }
}
