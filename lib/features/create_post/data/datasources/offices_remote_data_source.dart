import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/create_post/models/office_model.dart';

abstract class OfficesRemoteDataSource {
  Future<OfficesPageModel> getOffices({String search = ''});

  Future<OfficeModel> getOfficeById(int officeId);
}

class OfficesRemoteDataSourceImpl implements OfficesRemoteDataSource {
  const OfficesRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<OfficesPageModel> getOffices({String search = ''}) async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.offices}');

    final Map<String, dynamic> query = <String, dynamic>{};
    final String trimmed = search.trim();
    if (trimmed.isNotEmpty) {
      query['search'] = trimmed;
      query['name'] = trimmed;
    }

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.offices,
      queryParameters: query.isEmpty ? null : query,
    );

    final ApiEnvelope envelope = ApiEnvelope.from(response.data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: response.statusCode,
      );
    }

    return OfficesPageModel.fromEnvelope(envelope.data);
  }

  @override
  Future<OfficeModel> getOfficeById(int officeId) async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.officeById(officeId)}');

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.officeById(officeId),
    );

    final ApiEnvelope envelope = ApiEnvelope.from(response.data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: response.statusCode,
      );
    }

    final dynamic data = envelope.data;
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    final Object? officeRaw = map['office'] ?? map;
    final Map<String, dynamic> office = officeRaw is Map
        ? Map<String, dynamic>.from(officeRaw)
        : map;

    return OfficeModel.fromJson(office);
  }
}
