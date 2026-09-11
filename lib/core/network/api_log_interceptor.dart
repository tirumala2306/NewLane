import 'package:dio/dio.dart';
import 'package:newlane/core/utils/app_log.dart';

/// Debug-only request/response logger. Redacts auth and credential fields.
class ApiLogInterceptor extends Interceptor {
  static const Set<String> _sensitiveKeys = <String>{
    'authorization',
    'password',
    'confirmPassword',
    'token',
    'accessToken',
    'refreshToken',
    'auth_token',
    'fcm_token',
    'otp',
    'pin',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLog.section('API REQUEST', <String, Object?>{
      'METHOD': options.method,
      'URL': options.uri.toString(),
      'HEADERS': _redactMap(options.headers),
      'QUERY': _redactMap(options.queryParameters),
      'BODY': _redactBody(options.data),
    });
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLog.section('API RESPONSE', <String, Object?>{
      'STATUS': '${response.statusCode} ${response.statusMessage ?? ''}'.trim(),
      'URL': response.requestOptions.uri.toString(),
      'BODY': _redactBody(response.data),
    });
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLog.section('API ERROR', <String, Object?>{
      'TYPE': err.type.name,
      'STATUS': err.response?.statusCode,
      'URL': err.requestOptions.uri.toString(),
      'MESSAGE': err.message,
      'BODY': _redactBody(err.response?.data),
    });
    handler.next(err);
  }

  static Object? _redactBody(Object? data) {
    if (data is FormData) {
      return <String, Object?>{
        'fields': data.fields
            .map(
              (MapEntry<String, String> e) => <String, String>{
                e.key: _isSensitive(e.key) ? '***' : e.value,
              },
            )
            .toList(),
        'files': data.files.map((e) => e.key).toList(),
      };
    }
    if (data is Map) {
      return _redactMap(Map<String, dynamic>.from(data));
    }
    return data;
  }

  static Map<String, Object?> _redactMap(Map<dynamic, dynamic> source) {
    final Map<String, Object?> out = <String, Object?>{};
    source.forEach((dynamic key, dynamic value) {
      final String k = key.toString();
      if (_isSensitive(k)) {
        out[k] = '***';
      } else if (value is Map) {
        out[k] = _redactMap(Map<String, dynamic>.from(value));
      } else {
        out[k] = value;
      }
    });
    return out;
  }

  static bool _isSensitive(String key) {
    final String normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final String sensitive in _sensitiveKeys) {
      final String s = sensitive.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      if (normalized.contains(s)) return true;
    }
    return false;
  }
}
