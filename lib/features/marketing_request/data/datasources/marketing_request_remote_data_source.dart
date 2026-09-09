import 'package:dio/dio.dart';
import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/marketing_request/models/marketing_request_model.dart';

abstract class MarketingRequestRemoteDataSource {
  Future<MarketingRequestSubmitModel> createRequest({
    required String requestType,
    required String listingAddress,
    required String listingPrice,
    required String notes,
    List<String> mediaPaths = const <String>[],
  });

  Future<MarketingRequestListModel> getRequests({
    String status = 'active',
    String search = '',
  });

  Future<MarketingRequestModel> getRequestById(int id);
}

class MarketingRequestRemoteDataSourceImpl
    implements MarketingRequestRemoteDataSource {
  const MarketingRequestRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<MarketingRequestSubmitModel> createRequest({
    required String requestType,
    required String listingAddress,
    required String listingPrice,
    required String notes,
    List<String> mediaPaths = const <String>[],
  }) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.marketingRequests}');

    final FormData formData = FormData();
    formData.fields.addAll(<MapEntry<String, String>>[
      MapEntry<String, String>('requestType', requestType),
      MapEntry<String, String>('listingAddress', listingAddress),
      MapEntry<String, String>('listingPrice', listingPrice),
      MapEntry<String, String>('notes', notes),
    ]);

    for (final String path in mediaPaths) {
      final String trimmed = path.trim();
      if (trimmed.isEmpty) continue;
      final String fileName = trimmed.split(RegExp(r'[\\/]')).last;
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'media',
          await MultipartFile.fromFile(trimmed, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.marketingRequests,
      data: formData,
    );

    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return MarketingRequestSubmitModel.fromEnvelope(
      message: envelope.message,
      data: envelope.data,
    );
  }

  @override
  Future<MarketingRequestListModel> getRequests({
    String status = 'active',
    String search = '',
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'status': status.trim().isEmpty ? 'active' : status.trim(),
    };
    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    AppLog.line(
      '[DATA SOURCE] GET ${ApiEndpoints.marketingRequestsMine}'
      '?status=${query['status']}',
    );
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.marketingRequestsMine,
      queryParameters: query,
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return MarketingRequestListModel.fromEnvelope(envelope.data);
  }

  @override
  Future<MarketingRequestModel> getRequestById(int id) async {
    final String path = ApiEndpoints.marketingRequestById(id);
    AppLog.line('[DATA SOURCE] GET $path');
    final response = await _apiClient.get<dynamic>(path);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );

    final Object? raw = envelope.data;
    final Map<String, dynamic> map;
    if (raw is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
      final Object? nested = data['request'] ?? data['marketingRequest'];
      map = nested is Map ? Map<String, dynamic>.from(nested) : data;
    } else {
      map = <String, dynamic>{};
    }
    return MarketingRequestModel.fromJson(map);
  }

  ApiEnvelope _requireSuccess(dynamic data, int? statusCode) {
    final ApiEnvelope envelope = ApiEnvelope.from(data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: statusCode,
      );
    }
    return envelope;
  }
}
