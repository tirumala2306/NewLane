import 'package:dio/dio.dart';
import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/support/models/support_ticket_model.dart';

abstract class SupportRemoteDataSource {
  Future<SupportTicketListModel> getMyTickets({int? currentUserId});

  Future<SupportTicketModel> getTicketById(
    int ticketId, {
    int? currentUserId,
  });

  Future<SupportTicketModel> createTicket({
    required String category,
    required String subject,
    required String description,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  });

  Future<SupportTicketModel> replyToTicket({
    required int ticketId,
    required String message,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  const SupportRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SupportTicketListModel> getMyTickets({int? currentUserId}) async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.supportTicketsMine}');
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.supportTicketsMine,
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return SupportTicketListModel.fromEnvelope(
      envelope.data,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<SupportTicketModel> getTicketById(
    int ticketId, {
    int? currentUserId,
  }) async {
    final String path = ApiEndpoints.supportTicketById(ticketId);
    AppLog.line('[DATA SOURCE] GET $path');
    final response = await _apiClient.get<dynamic>(path);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return _ticketFromData(envelope.data, currentUserId: currentUserId);
  }

  @override
  Future<SupportTicketModel> createTicket({
    required String category,
    required String subject,
    required String description,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  }) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.supportTickets}');
    final FormData formData = FormData();
    formData.fields.addAll(<MapEntry<String, String>>[
      MapEntry<String, String>('category', category),
      MapEntry<String, String>('subject', subject),
      MapEntry<String, String>('description', description),
    ]);

    for (final String path in attachmentPaths) {
      final String trimmed = path.trim();
      if (trimmed.isEmpty) continue;
      final String fileName = trimmed.split(RegExp(r'[\\/]')).last;
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'attachments',
          await MultipartFile.fromFile(trimmed, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.supportTickets,
      data: formData,
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return _ticketFromData(envelope.data, currentUserId: currentUserId);
  }

  @override
  Future<SupportTicketModel> replyToTicket({
    required int ticketId,
    required String message,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  }) async {
    final String path = ApiEndpoints.supportTicketReply(ticketId);
    AppLog.line('[DATA SOURCE] POST $path');

    final FormData formData = FormData();
    formData.fields.add(MapEntry<String, String>('message', message.trim()));
    for (final String filePath in attachmentPaths) {
      final String trimmed = filePath.trim();
      if (trimmed.isEmpty) continue;
      final String fileName = trimmed.split(RegExp(r'[\\/]')).last;
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'attachments',
          await MultipartFile.fromFile(trimmed, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.post<dynamic>(path, data: formData);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return _ticketFromData(envelope.data, currentUserId: currentUserId);
  }

  SupportTicketModel _ticketFromData(
    dynamic data, {
    int? currentUserId,
  }) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? nested = map['ticket'] ?? map['supportTicket'];
      final Map<String, dynamic> source = nested is Map
          ? Map<String, dynamic>.from(nested)
          : map;
      return SupportTicketModel.fromJson(
        source,
        currentUserId: currentUserId,
      );
    }
    return SupportTicketModel.fromJson(
      <String, dynamic>{},
      currentUserId: currentUserId,
    );
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
