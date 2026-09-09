import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/directory/models/directory_agent_model.dart';

abstract class DirectoryRemoteDataSource {
  Future<DirectoryAgentsPageModel> getAgents({
    String search = '',
    String office = '',
    String specialty = '',
    String sort = 'name_asc',
  });

  Future<DirectoryAgentsPageModel> getTeam({
    String search = '',
    String department = 'All',
  });

  Future<DirectoryAgentModel> getAgentById(int agentId);
}

class DirectoryRemoteDataSourceImpl implements DirectoryRemoteDataSource {
  const DirectoryRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DirectoryAgentsPageModel> getAgents({
    String search = '',
    String office = '',
    String specialty = '',
    String sort = 'name_asc',
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'search': search.trim(),
      'office': office.trim(),
      'specialty': specialty.trim(),
      'sort': sort.trim().isEmpty ? 'name_asc' : sort.trim(),
    };

    AppLog.line(
      '[DATA SOURCE] GET ${ApiEndpoints.directoryAgents}'
      '?search=${query['search']}&office=${query['office']}'
      '&specialty=${query['specialty']}&sort=${query['sort']}',
    );

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.directoryAgents,
      queryParameters: query,
    );

    final ApiEnvelope envelope = ApiEnvelope.from(response.data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: response.statusCode,
      );
    }

    return DirectoryAgentsPageModel.fromEnvelope(envelope.data);
  }

  @override
  Future<DirectoryAgentsPageModel> getTeam({
    String search = '',
    String department = 'All',
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'department': department.trim().isEmpty ? 'All' : department.trim(),
    };
    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    AppLog.line(
      '[DATA SOURCE] GET ${ApiEndpoints.directoryTeam}'
      '?department=${query['department']}'
      '${search.trim().isEmpty ? '' : '&search=${search.trim()}'}',
    );

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.directoryTeam,
      queryParameters: query,
    );

    final ApiEnvelope envelope = ApiEnvelope.from(response.data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: response.statusCode,
      );
    }

    return DirectoryAgentsPageModel.fromEnvelope(
      envelope.data,
      teamFirst: true,
    );
  }

  @override
  Future<DirectoryAgentModel> getAgentById(int agentId) async {
    final String path = ApiEndpoints.directoryAgentById(agentId);
    AppLog.line('[DATA SOURCE] GET $path');

    final response = await _apiClient.get<dynamic>(path);
    final ApiEnvelope envelope = ApiEnvelope.from(response.data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: response.statusCode,
      );
    }

    final Object? data = envelope.data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? nested =
          map['agent'] ?? map['user'] ?? map['member'] ?? map['data'];
      if (nested is Map) {
        return DirectoryAgentModel.fromJson(
          Map<String, dynamic>.from(nested),
        );
      }
      return DirectoryAgentModel.fromJson(map);
    }

    throw const ServerException('Invalid agent response.');
  }
}
