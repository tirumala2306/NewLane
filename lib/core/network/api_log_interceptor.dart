import 'package:dio/dio.dart';
import 'package:newlane/core/utils/app_log.dart';

/// Prints every request, response, and error in plain stdout.
class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLog.section('API REQUEST', <String, Object?>{
      'METHOD': options.method,
      'URL': options.uri.toString(),
      'HEADERS': options.headers,
      'QUERY': options.queryParameters,
      'BODY': options.data,
    });
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLog.section('API RESPONSE', <String, Object?>{
      'STATUS': '${response.statusCode} ${response.statusMessage ?? ''}'.trim(),
      'URL': response.requestOptions.uri.toString(),
      'BODY': response.data,
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
      'BODY': err.response?.data,
    });
    handler.next(err);
  }
}
