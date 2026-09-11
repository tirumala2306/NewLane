import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/firebase/firebase_bootstrap.dart';
import 'package:newlane/core/router/app_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/storage/app_storage.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/notifications/data/devices_remote_data_source.dart';
import 'package:newlane/features/notifications/data/push_notification_prefs.dart';
import 'package:newlane/firebase_options.dart';

/// Top-level background handler (must be a top-level or static function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty && DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  AppLog.line(
    '[PUSH] background message id=${message.messageId} type=${message.data['type']}',
  );
}

typedef PushNavigationHandler = void Function(Map<String, dynamic> data);

/// iOS-first FCM bootstrap: permission, token sync, foreground banners, taps.
class PushNotificationService {
  PushNotificationService({
    required AppStorage storage,
    required DevicesRemoteDataSource devicesRemote,
    required PushNotificationPrefsStore prefsStore,
  }) : _storage = storage,
       _devicesRemote = devicesRemote,
       _prefsStore = prefsStore;

  final AppStorage _storage;
  final DevicesRemoteDataSource _devicesRemote;
  final PushNotificationPrefsStore _prefsStore;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _currentToken;
  PushNavigationHandler? onNavigate;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'newlane_default',
    'NewLane Notifications',
    description: 'Messages, tickets, and announcements',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    if (!FirebaseBootstrap.isReady) {
      AppLog.line('[PUSH] skipped — Firebase not ready');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();

    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLog.line('[PUSH] permission=${settings.authorizationStatus}');

    if (!kIsWeb && Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidLocal = _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted =
          await androidLocal?.requestNotificationsPermission();
      AppLog.line('[PUSH] android POST_NOTIFICATIONS granted=$granted');
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      // Defer until router is ready.
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 800), () {
          _handleMessageTap(initial);
        }),
      );
    }

    _messaging.onTokenRefresh.listen((String token) {
      unawaited(_onNewToken(token));
    });

    if (_storage.hasAuthToken) {
      await syncTokenWithBackend();
    }

    _initialized = true;
    AppLog.line('[PUSH] service ready');
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _navigateFromPayload(payload);
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// Call after successful login / session restore.
  Future<void> syncTokenWithBackend() async {
    if (!FirebaseBootstrap.isReady) return;
    try {
      final String? token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        AppLog.line('[PUSH] no FCM token yet');
        return;
      }
      await _onNewToken(token);
    } catch (error) {
      AppLog.line('[PUSH] getToken failed: $error');
    }
  }

  Future<void> _onNewToken(String token) async {
    _currentToken = token;
    await _storage.saveString(AppConstants.fcmTokenKey, token);
    AppLog.line('[PUSH] fcm token length=${token.length}');

    if (!_storage.hasAuthToken) return;

    final PushNotificationPrefs prefs = _prefsStore.read();
    if (!prefs.enabled) {
      AppLog.line('[PUSH] push disabled — skip register');
      return;
    }

    final String platform = kIsWeb
        ? 'web'
        : (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other'));

    try {
      await _devicesRemote.registerToken(token: token, platform: platform);
    } catch (_) {
      // Backend Phase 3 may not exist yet — keep trying on next login.
    }
  }

  Future<void> unregisterOnLogout() async {
    final String? token =
        _currentToken ?? _storage.readString(AppConstants.fcmTokenKey);
    if (token != null && token.isNotEmpty) {
      await _devicesRemote.unregisterToken(token: token);
    }
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    _currentToken = null;
    await _storage.remove(AppConstants.fcmTokenKey);
  }

  Future<void> applyPrefs(PushNotificationPrefs prefs) async {
    await _prefsStore.save(prefs);
    unawaited(_devicesRemote.syncPrefs(prefs));
    if (!prefs.enabled) {
      final String? token =
          _currentToken ?? _storage.readString(AppConstants.fcmTokenKey);
      if (token != null && token.isNotEmpty) {
        await _devicesRemote.unregisterToken(token: token);
      }
      return;
    }
    await syncTokenWithBackend();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final PushNotificationPrefs prefs = _prefsStore.read();
    if (!_shouldShow(message, prefs)) return;

    final RemoteNotification? notification = message.notification;
    final String title =
        notification?.title ?? message.data['title']?.toString() ?? 'NewLane';
    final String body =
        notification?.body ?? message.data['body']?.toString() ?? '';

    // iOS already presents via setForegroundNotificationPresentationOptions.
    // Still show local on Android; on iOS local helps when notification payload is data-only.
    await _local.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _encodePayload(message.data),
    );
  }

  bool _shouldShow(RemoteMessage message, PushNotificationPrefs prefs) {
    if (!prefs.enabled) return false;
    final String type = (message.data['type'] ?? '').toString().toLowerCase();
    if (type.contains('message') || type.contains('chat')) {
      return prefs.messages;
    }
    if (type.contains('ticket') || type.contains('support')) {
      return prefs.tickets;
    }
    if (type.contains('announce')) {
      return prefs.announcements;
    }
    if (type.contains('marketing') || type.contains('request')) {
      return prefs.marketing;
    }
    return prefs.system;
  }

  void _handleMessageTap(RemoteMessage message) {
    AppLog.line('[PUSH] opened type=${message.data['type']}');
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    if (onNavigate != null) {
      onNavigate!(data);
      return;
    }
    navigateFromData(data);
  }

  void _navigateFromPayload(String payload) {
    final Map<String, dynamic> data = _decodePayload(payload);
    if (onNavigate != null) {
      onNavigate!(data);
      return;
    }
    navigateFromData(data);
  }

  /// Shared navigation for notification taps.
  static void navigateFromData(Map<String, dynamic> data) {
    final String type = (data['type'] ?? '').toString().toLowerCase();
    final router = AppRouter.router;

    if (type.contains('message') || type.contains('chat')) {
      final String? chatId =
          data['conversationId']?.toString() ?? data['chatId']?.toString();
      if (chatId != null && chatId.isNotEmpty) {
        router.go(AppRoutes.conversationWithId(chatId));
        return;
      }
      router.go(AppRoutes.chat);
      return;
    }

    if (type.contains('ticket') || type.contains('support')) {
      final String? ticketId = data['ticketId']?.toString();
      if (ticketId != null && ticketId.isNotEmpty) {
        router.go(AppRoutes.ticketSupport);
        return;
      }
      router.go(AppRoutes.ticketSupport);
      return;
    }

    if (type.contains('announce')) {
      router.go(AppRoutes.home);
      return;
    }

    router.go(AppRoutes.home);
  }

  static String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  static Map<String, dynamic> _decodePayload(String payload) {
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final String part in payload.split('&')) {
      final int i = part.indexOf('=');
      if (i <= 0) continue;
      out[part.substring(0, i)] = part.substring(i + 1);
    }
    return out;
  }
}
