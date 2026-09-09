import 'package:dio/dio.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_log_interceptor.dart';
import 'package:newlane/core/network/auth_interceptor.dart';
import 'package:newlane/core/storage/app_storage.dart';

/// Thin Dio wrapper. Callers get [Response] or a typed exception.
class ApiClient {
  ApiClient({required AppStorage storage, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppEnvironment.baseUrl,
              connectTimeout: AppConstants.connectTimeout,
              receiveTimeout: AppConstants.receiveTimeout,
              sendTimeout: AppConstants.connectTimeout,
              headers: const <String, Object>{
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(AuthInterceptor(storage));
    _dio.interceptors.add(ApiLogInterceptor());
  }

  final Dio _dio;

  Dio get rawClient => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _mapDioError(error, 'GET');
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _mapDioError(error, 'POST');
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _mapDioError(error, 'PUT');
    }
  }

  /// Turns Dio errors into [NetworkException] or [ServerException].
  Never _mapDioError(DioException error, String method) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        throw const NetworkException(
          'Request timed out. Please check your connection and try again.',
        );
      case DioExceptionType.connectionError:
        throw const NetworkException(
          'No internet connection. Please check your network and try again.',
        );
      case DioExceptionType.cancel:
        throw ServerException('$method request was cancelled.');
      case DioExceptionType.badCertificate:
        throw const NetworkException('Could not verify the server certificate.');
      case DioExceptionType.badResponse:
        throw ServerException(
          _messageFrom(error),
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.unknown:
        throw NetworkException(_messageFrom(error));
    }
  }

  String _messageFrom(DioException error) {
    final Object? data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return error.message ?? 'Something went wrong. Please try again.';
  }
}
