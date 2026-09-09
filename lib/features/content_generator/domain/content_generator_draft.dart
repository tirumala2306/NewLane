enum ContentFormat {
  story('Story', '9:16', 9 / 16),
  post('Post', '1:1', 1),
  carousel('Carousel', '1.91:1', 1.91);

  const ContentFormat(this.label, this.ratioLabel, this.aspectRatio);

  final String label;
  final String ratioLabel;
  final double aspectRatio;

  static ContentFormat fromRaw(String? raw) {
    final String value = (raw ?? '').trim().toLowerCase();
    for (final ContentFormat format in ContentFormat.values) {
      if (format.label.toLowerCase() == value || format.name == value) {
        return format;
      }
    }
    return ContentFormat.story;
  }
}

class ContentGraphicFields {
  const ContentGraphicFields({
    this.brandLogo = 'NEWLANE',
    this.headline = 'JUST LISTED',
    this.address = '',
    this.price = '',
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.sqft = 0,
    this.tagline = 'Luxury Waterfront Living',
  });

  final String brandLogo;
  final String headline;
  final String address;
  final String price;
  final num bedrooms;
  final num bathrooms;
  final int sqft;
  final String tagline;

  factory ContentGraphicFields.fromJson(Map<String, dynamic> json) {
    return ContentGraphicFields(
      brandLogo: (json['brandLogo'] ?? 'NEWLANE').toString(),
      headline: (json['headline'] ?? 'JUST LISTED').toString(),
      address: (json['address'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
      bedrooms: _asNum(json['bedrooms']),
      bathrooms: _asNum(json['bathrooms']),
      sqft: _asInt(json['sqft']),
      tagline: (json['tagline'] ?? 'Luxury Waterfront Living').toString(),
    );
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value'.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}

class ContentGraphicSpec {
  const ContentGraphicSpec({
    required this.template,
    required this.format,
    required this.fields,
    this.category = 'Real Estate Listing',
  });

  final String template;
  final ContentFormat format;
  final ContentGraphicFields fields;
  final String category;

  factory ContentGraphicSpec.fromJson(Map<String, dynamic> json) {
    final Object? fieldsRaw = json['fields'];
    return ContentGraphicSpec(
      template: (json['template'] ?? 'Just Listed - Modern').toString(),
      format: ContentFormat.fromRaw((json['format'] ?? 'Story').toString()),
      category: (json['category'] ?? 'Real Estate Listing').toString(),
      fields: fieldsRaw is Map
          ? ContentGraphicFields.fromJson(Map<String, dynamic>.from(fieldsRaw))
          : const ContentGraphicFields(),
    );
  }

  ContentGraphicSpec copyWith({
    String? template,
    ContentFormat? format,
    ContentGraphicFields? fields,
    String? category,
  }) {
    return ContentGraphicSpec(
      template: template ?? this.template,
      format: format ?? this.format,
      fields: fields ?? this.fields,
      category: category ?? this.category,
    );
  }
}

class ContentTemplate {
  const ContentTemplate({
    required this.id,
    required this.name,
    this.category = 'Real Estate Listing',
  });

  final String id;
  final String name;
  final String category;

  factory ContentTemplate.fromJson(Map<String, dynamic> json) {
    return ContentTemplate(
      id: (json['id'] ?? json['_id'] ?? json['name'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? 'Just Listed - Modern').toString(),
      category: (json['category'] ?? json['type'] ?? 'Real Estate Listing')
          .toString(),
    );
  }
}

class ContentGenerateResult {
  const ContentGenerateResult({
    required this.caption,
    required this.graphicSpec,
  });

  final String caption;
  final ContentGraphicSpec graphicSpec;
}

/// Form + generate payload for the listing content generator.
class ContentGeneratorDraft {
  const ContentGeneratorDraft({
    this.photoPaths = const <String>[],
    this.propertyAddress = '',
    this.price = '',
    this.bedrooms = '',
    this.bathrooms = '',
    this.sqft = '',
    this.postType = 'Listing',
    this.tone = 'Professional',
    this.keyFeatures = const <String>[],
    this.additionalNotes = '',
    this.format = ContentFormat.story,
    this.templateName = 'Just Listed - Modern',
    this.generatedCaption = '',
    this.graphicSpec,
  });

  final List<String> photoPaths;
  final String propertyAddress;
  final String price;
  final String bedrooms;
  final String bathrooms;
  final String sqft;
  final String postType;
  final String tone;
  final List<String> keyFeatures;
  final String additionalNotes;
  final ContentFormat format;
  final String templateName;
  final String generatedCaption;
  final ContentGraphicSpec? graphicSpec;

  static ContentGeneratorDraft fromExtra(Object? extra) {
    if (extra is ContentGeneratorDraft) return extra;
    return const ContentGeneratorDraft();
  }

  ContentGeneratorDraft copyWith({
    List<String>? photoPaths,
    String? propertyAddress,
    String? price,
    String? bedrooms,
    String? bathrooms,
    String? sqft,
    String? postType,
    String? tone,
    List<String>? keyFeatures,
    String? additionalNotes,
    ContentFormat? format,
    String? templateName,
    String? generatedCaption,
    ContentGraphicSpec? graphicSpec,
    bool clearGraphicSpec = false,
  }) {
    return ContentGeneratorDraft(
      photoPaths: photoPaths ?? this.photoPaths,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      price: price ?? this.price,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      sqft: sqft ?? this.sqft,
      postType: postType ?? this.postType,
      tone: tone ?? this.tone,
      keyFeatures: keyFeatures ?? this.keyFeatures,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      format: format ?? this.format,
      templateName: templateName ?? this.templateName,
      generatedCaption: generatedCaption ?? this.generatedCaption,
      graphicSpec: clearGraphicSpec ? null : (graphicSpec ?? this.graphicSpec),
    );
  }

  int get priceValue {
    final String digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  num get bedroomsValue {
    final num? fromField = num.tryParse(bedrooms.trim());
    if (fromField != null) return fromField;
    return _featureNum(RegExp(r'(\d+(?:\.\d+)?)\s*bed', caseSensitive: false));
  }

  num get bathroomsValue {
    final num? fromField = num.tryParse(bathrooms.trim());
    if (fromField != null) return fromField;
    return _featureNum(RegExp(r'(\d+(?:\.\d+)?)\s*bath', caseSensitive: false));
  }

  int get sqftValue {
    final int? fromField = int.tryParse(
      sqft.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (fromField != null) return fromField;
    return _featureNum(
      RegExp(r'(\d[\d,]*)\s*(?:sq\.?\s*ft|sqft)', caseSensitive: false),
    ).toInt();
  }

  num _featureNum(RegExp pattern) {
    for (final String feature in keyFeatures) {
      final Match? match = pattern.firstMatch(feature);
      if (match != null) {
        return num.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
      }
    }
    return 0;
  }
}
