import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:newlane/core/config/app_environment.dart';

/// Production-safe logger. No-ops in release / production so tokens and
/// credentials never appear in device logs.
class AppLog {
  const AppLog._();

  static const String _rule =
      '============================================================';

  static bool get _enabled {
    if (kReleaseMode) return false;
    if (AppEnvironment.type.isProduction) return false;
    return true;
  }

  /// Single line.
  static void line(String message) {
    if (!_enabled) return;
    debugPrint(message);
  }

  /// Block with a title and key/value rows.
  static void section(
    String title, [
    Map<String, Object?> fields = const <String, Object?>{},
  ]) {
    if (!_enabled) return;
    debugPrint(_rule);
    debugPrint('[$title]');
    for (final MapEntry<String, Object?> entry in fields.entries) {
      debugPrint('  ${entry.key}: ${_stringify(entry.value)}');
    }
    debugPrint(_rule);
  }

  static String prettyJson(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String _stringify(Object? value) {
    if (value == null) return 'null';
    if (value is Map || value is List) return '\n${prettyJson(value)}';
    return value.toString();
  }
}
