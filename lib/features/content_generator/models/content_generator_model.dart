import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';

class ContentGenerateResultModel {
  const ContentGenerateResultModel({
    required this.caption,
    required this.graphicSpec,
  });

  factory ContentGenerateResultModel.fromEnvelope(dynamic data) {
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    final Object? specRaw = map['graphicSpec'] ?? map['graphic'];
    return ContentGenerateResultModel(
      caption: (map['caption'] ?? map['text'] ?? '').toString(),
      graphicSpec: specRaw is Map
          ? ContentGraphicSpec.fromJson(Map<String, dynamic>.from(specRaw))
          : const ContentGraphicSpec(
              template: 'Just Listed - Modern',
              format: ContentFormat.story,
              fields: ContentGraphicFields(),
            ),
    );
  }

  final String caption;
  final ContentGraphicSpec graphicSpec;

  ContentGenerateResult toEntity() {
    return ContentGenerateResult(caption: caption, graphicSpec: graphicSpec);
  }
}

class ContentTemplateListModel {
  const ContentTemplateListModel({required this.templates});

  factory ContentTemplateListModel.fromEnvelope(dynamic data) {
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? raw = map['templates'] ?? map['items'] ?? map['data'];
      list = raw is List ? raw : const <dynamic>[];
    } else {
      list = const <dynamic>[];
    }

    final List<ContentTemplate> templates = list
        .whereType<Map>()
        .map(
          (Map item) =>
              ContentTemplate.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    if (templates.isEmpty) {
      return const ContentTemplateListModel(
        templates: <ContentTemplate>[
          ContentTemplate(id: 'just-listed-modern', name: 'Just Listed - Modern'),
          ContentTemplate(id: 'open-house', name: 'Open House Spotlight'),
          ContentTemplate(id: 'sold', name: 'Just Sold Classic'),
        ],
      );
    }
    return ContentTemplateListModel(templates: templates);
  }

  final List<ContentTemplate> templates;
}
