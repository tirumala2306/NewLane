import 'package:dio/dio.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/storage/app_storage.dart';

/// Attaches Bearer token from local storage on every request when present.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final AppStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _storage.readString(AppConstants.authTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Let Dio set multipart boundary for file uploads.
    if (options.data is FormData) {
      options.headers.remove(Headers.contentTypeHeader);
    }
    handler.next(options);
  }
}
