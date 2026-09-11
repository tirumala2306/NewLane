import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/storage/app_storage.dart';
import 'package:newlane/core/utils/app_log.dart';

/// Local push preference toggles (synced to backend when API is ready).
class PushNotificationPrefs {
  const PushNotificationPrefs({
    this.enabled = true,
    this.messages = true,
    this.tickets = true,
    this.announcements = true,
    this.marketing = false,
    this.system = true,
  });

  final bool enabled;
  final bool messages;
  final bool tickets;
  final bool announcements;
  final bool marketing;
  final bool system;

  PushNotificationPrefs copyWith({
    bool? enabled,
    bool? messages,
    bool? tickets,
    bool? announcements,
    bool? marketing,
    bool? system,
  }) {
    return PushNotificationPrefs(
      enabled: enabled ?? this.enabled,
      messages: messages ?? this.messages,
      tickets: tickets ?? this.tickets,
      announcements: announcements ?? this.announcements,
      marketing: marketing ?? this.marketing,
      system: system ?? this.system,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'enabled': enabled,
      'messages': messages,
      'tickets': tickets,
      'announcements': announcements,
      'marketing': marketing,
      'system': system,
    };
  }
}

class PushNotificationPrefsStore {
  PushNotificationPrefsStore(this._storage);

  final AppStorage _storage;

  bool _readBool(String key, {required bool fallback}) {
    final String? raw = _storage.readString(key);
    if (raw == null) return fallback;
    return raw == 'true';
  }

  Future<void> _writeBool(String key, bool value) {
    return _storage.saveString(key, value ? 'true' : 'false');
  }

  PushNotificationPrefs read() {
    return PushNotificationPrefs(
      enabled: _readBool(AppConstants.pushEnabledKey, fallback: true),
      messages: _readBool(AppConstants.pushMessagesKey, fallback: true),
      tickets: _readBool(AppConstants.pushTicketsKey, fallback: true),
      announcements: _readBool(AppConstants.pushAnnouncementsKey, fallback: true),
      marketing: _readBool(AppConstants.pushMarketingKey, fallback: false),
      system: _readBool(AppConstants.pushSystemKey, fallback: true),
    );
  }

  Future<void> save(PushNotificationPrefs prefs) async {
    await _writeBool(AppConstants.pushEnabledKey, prefs.enabled);
    await _writeBool(AppConstants.pushMessagesKey, prefs.messages);
    await _writeBool(AppConstants.pushTicketsKey, prefs.tickets);
    await _writeBool(AppConstants.pushAnnouncementsKey, prefs.announcements);
    await _writeBool(AppConstants.pushMarketingKey, prefs.marketing);
    await _writeBool(AppConstants.pushSystemKey, prefs.system);
    AppLog.line('[PUSH] prefs saved enabled=${prefs.enabled}');
  }
}
