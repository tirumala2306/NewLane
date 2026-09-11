import 'package:newlane/features/notifications/domain/entities/app_notification.dart';

class AppNotificationModel {
  const AppNotificationModel({
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

  factory AppNotificationModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    final String title = (json['title'] ?? json['subject'] ?? '').toString();
    final String body =
        (json['body'] ?? json['message'] ?? json['description'] ?? '').toString();
    final String type = (json['type'] ??
            json['notificationType'] ??
            json['notification_type'] ??
            json['category'] ??
            '')
        .toString();

    return AppNotificationModel(
      id: _asInt(json['id']) ?? 0,
      title: title.isEmpty ? 'Notification' : title,
      body: body,
      kind: parseNotificationKind(type: type, title: title, body: body),
      rawType: type,
      createdAt: _asDate(
            json['createdAt'] ??
                json['created_at'] ??
                json['sentAt'] ??
                json['sent_at'] ??
                json['sent'],
          ) ??
          DateTime.now(),
      isUnread: _isUnread(json, currentUserId: currentUserId),
      thumbnailUrl: (json['thumbnailUrl'] ??
              json['thumbnail'] ??
              json['imageUrl'] ??
              json['image'])
          ?.toString(),
      deepLink: (json['deepLink'] ?? json['deep_link'] ?? json['link'])
          ?.toString(),
    );
  }

  final int id;
  final String title;
  final String body;
  final AppNotificationKind kind;
  final DateTime createdAt;
  final bool isUnread;
  final String? thumbnailUrl;
  final String? deepLink;
  final String rawType;

  AppNotification toEntity() => AppNotification(
        id: id,
        title: title,
        body: body,
        kind: kind,
        createdAt: createdAt,
        isUnread: isUnread,
        thumbnailUrl: thumbnailUrl,
        deepLink: deepLink,
        rawType: rawType,
      );

  static bool _isUnread(Map<String, dynamic> json, {int? currentUserId}) {
    if (json.containsKey('isRead') || json.containsKey('is_read')) {
      return !(_asBool(json['isRead'] ?? json['is_read']) ?? false);
    }
    if (json.containsKey('isUnread') || json.containsKey('is_unread')) {
      return _asBool(json['isUnread'] ?? json['is_unread']) ?? true;
    }
    // DB: read_by JSON array of user ids who read it.
    final Object? readBy = json['readBy'] ?? json['read_by'];
    if (readBy is List && currentUserId != null && currentUserId > 0) {
      for (final Object? id in readBy) {
        if (_asInt(id) == currentUserId) return false;
      }
      return true;
    }
    if (readBy is String && currentUserId != null) {
      return !readBy.contains('$currentUserId');
    }
    return true;
  }

  static int? _asInt(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static bool? _asBool(Object? raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final String s = raw.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return null;
  }

  static DateTime? _asDate(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString());
  }
}

List<AppNotificationModel> parseNotificationsList(
  dynamic data, {
  int? currentUserId,
}) {
  dynamic list = data;
  if (data is Map) {
    list = data['notifications'] ??
        data['items'] ??
        data['rows'] ??
        data['data'] ??
        data;
  }
  if (list is! List) return <AppNotificationModel>[];
  final List<AppNotificationModel> out = <AppNotificationModel>[];
  for (final Object? item in list) {
    if (item is Map) {
      out.add(
        AppNotificationModel.fromJson(
          Map<String, dynamic>.from(item),
          currentUserId: currentUserId,
        ),
      );
    }
  }
  return out;
}
