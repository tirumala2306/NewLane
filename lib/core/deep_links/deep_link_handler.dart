import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/utils/app_log.dart';

/// Routes email activation / reset-password links into the app.
class DeepLinkHandler {
  DeepLinkHandler._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _subscription;

  static Future<void> init(GoRouter router) async {
    await _subscription?.cancel();

    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      // Wait until the first frame so GoRouter is ready.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _navigateFromUri(router, initialUri);
      });
    }

    _subscription = _appLinks.uriLinkStream.listen(
      (Uri uri) => _navigateFromUri(router, uri),
      onError: (Object error) {
        AppLog.line('[DEEP LINK] stream error: $error');
      },
    );
  }

  static void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  /// Used by GoRouter redirect for activation / reset deep links.
  static String? redirectForActivation(Uri uri) {
    final String? resetToken =
        resetTokenFromUri(uri) ?? resetTokenFromRaw(uri.toString());
    if (resetToken != null && resetToken.isNotEmpty) {
      final String target = AppRoutes.resetPasswordWithToken(resetToken);
      if (uri.path == target || uri.path.endsWith(target)) {
        return null;
      }
      return target;
    }

    final String? token = activationTokenFromUri(uri) ??
        activationTokenFromRaw(uri.toString());
    if (token == null || token.isEmpty) return null;

    final String target = AppRoutes.createPasswordWithToken(token);
    if (uri.path == target || uri.path.endsWith(target)) {
      return null;
    }
    return target;
  }

  static String? activationTokenFromUri(Uri uri) {
    // newlane://activate/<token>
    if (uri.scheme == 'newlane' &&
        (uri.host == 'activate' || uri.pathSegments.contains('activate'))) {
      if (uri.host == 'activate') {
        return _firstNonEmptySegment(uri.pathSegments);
      }
      final int index = uri.pathSegments.indexOf('activate');
      if (index >= 0 && index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }

    // https://host/activate/<token>  or  /activate/<token>
    if (uri.pathSegments.isNotEmpty) {
      final int index = uri.pathSegments.indexOf('activate');
      if (index >= 0 && index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }

    return null;
  }

  static String? resetTokenFromUri(Uri uri) {
    // newlane://reset-password/<token>
    if (uri.scheme == 'newlane' &&
        (uri.host == 'reset-password' ||
            uri.pathSegments.contains('reset-password'))) {
      if (uri.host == 'reset-password') {
        return _firstNonEmptySegment(uri.pathSegments);
      }
      final int index = uri.pathSegments.indexOf('reset-password');
      if (index >= 0 && index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }

    // http(s)://host/reset-password/<token>
    if (uri.pathSegments.isNotEmpty) {
      final int index = uri.pathSegments.indexOf('reset-password');
      if (index >= 0 && index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }

    return null;
  }

  static String? activationTokenFromRaw(String raw) {
    const String custom = 'newlane://activate/';
    if (raw.startsWith(custom)) {
      final String rest = raw.substring(custom.length);
      return rest.split(RegExp(r'[?#/]')).firstWhere(
        (String part) => part.isNotEmpty,
        orElse: () => '',
      );
    }

    final RegExp pathPattern = RegExp(r'/activate/([^/?#]+)');
    final Match? match = pathPattern.firstMatch(raw);
    return match?.group(1);
  }

  static String? resetTokenFromRaw(String raw) {
    const String custom = 'newlane://reset-password/';
    if (raw.startsWith(custom)) {
      final String rest = raw.substring(custom.length);
      return rest.split(RegExp(r'[?#/]')).firstWhere(
        (String part) => part.isNotEmpty,
        orElse: () => '',
      );
    }

    final RegExp pathPattern = RegExp(r'/reset-password/([^/?#]+)');
    final Match? match = pathPattern.firstMatch(raw);
    return match?.group(1);
  }

  static void _navigateFromUri(GoRouter router, Uri uri) {
    final String? resetToken =
        resetTokenFromUri(uri) ?? resetTokenFromRaw(uri.toString());
    if (resetToken != null && resetToken.isNotEmpty) {
      AppLog.line('[DEEP LINK] reset-password token received');
      router.go(AppRoutes.resetPasswordWithToken(resetToken));
      return;
    }

    final String? token =
        activationTokenFromUri(uri) ?? activationTokenFromRaw(uri.toString());
    if (token == null || token.isEmpty) {
      AppLog.line('[DEEP LINK] ignored uri=$uri');
      return;
    }

    AppLog.line('[DEEP LINK] activate token received');
    router.go(AppRoutes.createPasswordWithToken(token));
  }

  static String? _firstNonEmptySegment(List<String> segments) {
    for (final String segment in segments) {
      if (segment.isNotEmpty) {
        return segment;
      }
    }
    return null;
  }
}
