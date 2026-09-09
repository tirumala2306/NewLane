import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:newlane/core/config/environment_type.dart';

class AppEnvironment {
  const AppEnvironment._();

  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const String _compileTimeBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const bool enableNetworkLogs = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGS',
    defaultValue: false,
  );

  static String _resolvedBaseUrl = _compileTimeBaseUrl;
  static bool _initialized = false;

  static EnvironmentType get type => EnvironmentType.fromName(_environmentName);
  static String get name => type.name;
  static String get baseUrl => _resolvedBaseUrl;
  static bool get showEnvironmentBanner => !type.isProduction;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    if (_compileTimeBaseUrl.isNotEmpty) {
      return;
    }

    if (kReleaseMode) {
      return;
    }

    await _loadFallbackFromAsset();
  }

  static Future<void> _loadFallbackFromAsset() async {
    try {
      final rawJson = await rootBundle.loadString(
        'config/env/development.json',
      );
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      _resolvedBaseUrl = data['API_BASE_URL']?.toString() ?? '';
    } on FlutterError {
      _resolvedBaseUrl = '';
    }
  }

  static void validate() {
    final uri = Uri.tryParse(_resolvedBaseUrl);

    if (_resolvedBaseUrl.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL is not configured. '
        'Pass --dart-define-from-file=config/env/development.json or set '
        'API_BASE_URL manually.',
      );
    }

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL is invalid: "$_resolvedBaseUrl"');
    }

    if (kReleaseMode && !type.isProduction) {
      throw StateError('Release builds must set APP_ENV=production.');
    }

    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('Release builds must use HTTPS API endpoints.');
    }
  }
}
