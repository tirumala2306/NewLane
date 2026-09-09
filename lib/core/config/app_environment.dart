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

    // Release IPA also needs a URL if dart-defines were omitted.
    await _loadFallbackFromAsset();
  }

  static Future<void> _loadFallbackFromAsset() async {
    final String fileName = switch (type) {
      EnvironmentType.production => 'production.json',
      EnvironmentType.staging => 'staging.json',
      EnvironmentType.development => 'development.json',
    };

    try {
      final String rawJson = await rootBundle.loadString(
        'config/env/$fileName',
      );
      final Map<String, dynamic> data =
          jsonDecode(rawJson) as Map<String, dynamic>;
      _resolvedBaseUrl = data['API_BASE_URL']?.toString() ?? '';
    } on FlutterError {
      // Last resort: try development config so the app can still boot.
      if (fileName != 'development.json') {
        try {
          final String rawJson = await rootBundle.loadString(
            'config/env/development.json',
          );
          final Map<String, dynamic> data =
              jsonDecode(rawJson) as Map<String, dynamic>;
          _resolvedBaseUrl = data['API_BASE_URL']?.toString() ?? '';
        } on FlutterError {
          _resolvedBaseUrl = '';
        }
      } else {
        _resolvedBaseUrl = '';
      }
    }
  }

  static void validate() {
    final Uri? uri = Uri.tryParse(_resolvedBaseUrl);

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

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw StateError(
        'API_BASE_URL must use http or https: "$_resolvedBaseUrl"',
      );
    }
  }
}
