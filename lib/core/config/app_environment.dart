import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:newlane/core/config/environment_type.dart';

class AppEnvironment {
  const AppEnvironment._();

  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: '',
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
  static EnvironmentType _resolvedType = EnvironmentType.development;

  static EnvironmentType get type => _resolvedType;
  static String get name => type.name;
  static String get baseUrl => _resolvedBaseUrl;
  static bool get showEnvironmentBanner => !type.isProduction;
  static bool get isNetworkLoggingEnabled =>
      enableNetworkLogs && !kReleaseMode && !type.isProduction;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _resolvedType = _resolveType();

    if (_compileTimeBaseUrl.isNotEmpty) {
      _resolvedBaseUrl = _compileTimeBaseUrl;
      return;
    }

    // Release IPA also needs a URL if dart-defines were omitted.
    await _loadFallbackFromAsset();
  }

  /// Release builds without `--dart-define APP_ENV` → production.
  /// Debug/profile without define → development.
  static EnvironmentType _resolveType() {
    final String raw = _environmentName.trim();
    if (raw.isNotEmpty) {
      return EnvironmentType.fromName(raw);
    }
    return kReleaseMode
        ? EnvironmentType.production
        : EnvironmentType.development;
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
      // Production must not silently fall back to development config.
      if (type.isProduction) {
        _resolvedBaseUrl = '';
        return;
      }
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
        'Pass --dart-define-from-file=config/env/production.json '
        '(or development.json for local).',
      );
    }

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL is invalid: "$_resolvedBaseUrl"');
    }

    if (type.isProduction || kReleaseMode) {
      if (uri.scheme != 'https') {
        throw StateError(
          'Production builds require HTTPS API_BASE_URL. Got: "$_resolvedBaseUrl"',
        );
      }
    } else if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw StateError(
        'API_BASE_URL must use http or https: "$_resolvedBaseUrl"',
      );
    }
  }
}
