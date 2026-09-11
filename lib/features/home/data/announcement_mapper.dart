import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/features/notifications/domain/entities/app_notification.dart';

HomeAnnouncement homeAnnouncementFromNotification(AppNotification n) {
  return HomeAnnouncement(
    id: n.id,
    kind: n.kind.name,
    title: n.title,
    subtitle: n.body,
    icon: n.icon,
    thumbnailUrl: n.thumbnailUrl,
    timeLabel: n.timeLabel,
    showUnreadDot: n.isUnread,
  );
}
