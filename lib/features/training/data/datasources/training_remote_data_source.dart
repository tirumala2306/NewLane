import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/training/data/models/training_resource_model.dart';

abstract class TrainingRemoteDataSource {
  Future<TrainingListModel> listResources({
    String? category,
    bool? featured,
  });

  Future<TrainingResourceModel> getResource(int id);
}

class TrainingRemoteDataSourceImpl implements TrainingRemoteDataSource {
  const TrainingRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TrainingListModel> listResources({
    String? category,
    bool? featured,
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (category != null && category.trim().isNotEmpty) {
      query['category'] = category.trim();
    }
    if (featured != null) {
      query['featured'] = featured ? '1' : '0';
    }
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.training}');
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.training,
      queryParameters: query.isEmpty ? null : query,
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return TrainingListModel.fromData(envelope.data);
  }

  @override
  Future<TrainingResourceModel> getResource(int id) async {
    final String path = ApiEndpoints.trainingById(id);
    AppLog.line('[DATA SOURCE] GET $path');
    final response = await _apiClient.get<dynamic>(path);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    final dynamic data = envelope.data;
    if (data is Map) {
      return TrainingResourceModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ServerException('Invalid training resource response');
  }

  ApiEnvelope _requireSuccess(dynamic raw, int? statusCode) {
    final ApiEnvelope envelope = ApiEnvelope.from(raw);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed' : envelope.message,
        statusCode: statusCode,
      );
    }
    return envelope;
  }
}
