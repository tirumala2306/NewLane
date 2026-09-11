import 'package:flutter/material.dart';

/// Normalized notification kinds used by home + notifications screens.
enum AppNotificationKind {
  announcement,
  training,
  agentJoined,
  ticket,
  marketing,
  message,
  system,
  other,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
    this.isUnread = true,
    this.thumbnailUrl,
    this.deepLink,
    this.rawType = '',
  });

  final int id;
  final String title;
  final String body;
  final AppNotificationKind kind;
  final DateTime createdAt;
  final bool isUnread;
  final String? thumbnailUrl;
  final String? deepLink;
  final String rawType;

  /// Home Announcements: office / training / new agent (not tickets/marketing).
  bool get showOnHomeAnnouncements {
    if (kind == AppNotificationKind.announcement ||
        kind == AppNotificationKind.training ||
        kind == AppNotificationKind.agentJoined) {
      return true;
    }
    final String t = rawType.toLowerCase();
    if (t == 'office_announcement' ||
        t == 'training_update' ||
        t == 'office_update' ||
        t == 'reminder' ||
        t == 'policy_update') {
      return true;
    }
    // Broadcasts sometimes stored as type=system with Office Announcement title.
    final String titleL = title.toLowerCase();
    if (titleL.contains('office announcement') ||
        titleL.contains('training') ||
        titleL.contains('new agent') ||
        titleL.contains('agent joined')) {
      return !titleL.contains('ticket') && !titleL.contains('marketing');
    }
    return false;
  }

  IconData get icon => switch (kind) {
        AppNotificationKind.announcement => Icons.campaign_outlined,
        AppNotificationKind.training => Icons.school_outlined,
        AppNotificationKind.agentJoined => Icons.person_add_alt_1_outlined,
        AppNotificationKind.ticket => Icons.support_agent_outlined,
        AppNotificationKind.marketing => Icons.assignment_outlined,
        AppNotificationKind.message => Icons.mail_outline,
        AppNotificationKind.system => Icons.notifications_outlined,
        AppNotificationKind.other => Icons.notifications_outlined,
      };

  String get timeLabel => formatNotificationTime(createdAt);
}

String formatNotificationTime(DateTime when) {
  final DateTime local = when.toLocal();
  final DateTime now = DateTime.now();
  final Duration diff = now.difference(local);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inHours < 12 && _sameDay(now, local)) {
    final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    final String period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  if (diff.inDays < 1 && !_sameDay(now, local)) return 'Yesterday';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Maps DB enum + title/body heuristics to app kinds.
///
/// DB enum:
/// office_announcement | new_message | marketing_request_update |
/// training_update | office_update | milestone | reminder | policy_update | system
AppNotificationKind parseNotificationKind({
  String? type,
  String? title,
  String? body,
}) {
  final String t = (type ?? '').trim().toLowerCase();
  final String titleL = (title ?? '').toLowerCase();
  final String bodyL = (body ?? '').toLowerCase();

  // Exact DB enum first.
  switch (t) {
    case 'office_announcement':
    case 'reminder':
    case 'policy_update':
      return AppNotificationKind.announcement;
    case 'training_update':
      return AppNotificationKind.training;
    case 'office_update':
      if (titleL.contains('agent') ||
          titleL.contains('trainer') ||
          bodyL.contains('welcome')) {
        return AppNotificationKind.agentJoined;
      }
      return AppNotificationKind.announcement;
    case 'marketing_request_update':
      return AppNotificationKind.marketing;
    case 'new_message':
      return AppNotificationKind.message;
    case 'milestone':
      return AppNotificationKind.system;
    case 'system':
      break; // fall through to title heuristics
  }

  if (titleL.contains('ticket') ||
      titleL.contains('support') ||
      bodyL.contains('ticket')) {
    return AppNotificationKind.ticket;
  }
  if (titleL.contains('marketing') || t.contains('marketing')) {
    return AppNotificationKind.marketing;
  }
  if (titleL.contains('training') || bodyL.contains('training')) {
    return AppNotificationKind.training;
  }
  if (titleL.contains('new agent') ||
      titleL.contains('agent joined') ||
      titleL.contains('trainer')) {
    return AppNotificationKind.agentJoined;
  }
  if (titleL.contains('announcement') ||
      titleL.contains('meeting') ||
      titleL.contains('office')) {
    return AppNotificationKind.announcement;
  }
  if (titleL.contains('message')) {
    return AppNotificationKind.message;
  }
  if (t == 'system') return AppNotificationKind.system;
  return AppNotificationKind.other;
}
