import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/models/content_generator_model.dart';

abstract class ContentGeneratorRemoteDataSource {
  Future<ContentGenerateResultModel> generate(ContentGeneratorDraft draft);

  Future<ContentTemplateListModel> getTemplates();
}

class ContentGeneratorRemoteDataSourceImpl
    implements ContentGeneratorRemoteDataSource {
  const ContentGeneratorRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ContentGenerateResultModel> generate(ContentGeneratorDraft draft) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.contentGeneratorGenerate}');
    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.contentGeneratorGenerate,
      data: <String, dynamic>{
        'propertyAddress': draft.propertyAddress.trim(),
        'price': draft.priceValue,
        'bedrooms': draft.bedroomsValue,
        'bathrooms': draft.bathroomsValue,
        'sqft': draft.sqftValue,
        'postType': draft.postType,
        'tone': draft.tone,
        'keyFeatures': draft.keyFeatures,
        'additionalNotes': draft.additionalNotes.trim(),
        'format': draft.format.label,
        if (draft.templateName.trim().isNotEmpty)
          'template': draft.templateName.trim(),
      },
    );

    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return ContentGenerateResultModel.fromEnvelope(envelope.data);
  }

  @override
  Future<ContentTemplateListModel> getTemplates() async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.contentGeneratorTemplates}');
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.contentGeneratorTemplates,
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return ContentTemplateListModel.fromEnvelope(envelope.data);
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
