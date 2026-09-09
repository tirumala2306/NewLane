import 'dart:convert';

import 'package:flutter/material.dart';

// Intentional: print() so logs show in stdout (not the blue debugPrint channel).
// ignore_for_file: avoid_print

/// Stdout logger (uses [print], not debugPrint — so Cursor/VS Code
/// shows it in the normal console color, not the blue Debug channel).
class AppLog {
  const AppLog._();

  static const String _rule = '============================================================';

  /// Single line.
  static void line(String message) {
    debugPrint(message);
  }

  /// Block with a title and key/value rows.
  static void section(String title, [Map<String, Object?> fields = const <String, Object?>{}]) {
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
