import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getMine({int? currentUserId});
}
