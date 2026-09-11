import 'package:newlane/features/training/domain/entities/training_resource.dart';

class TrainingResourceModel {
  const TrainingResourceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.fileUrl,
    this.description,
    this.fileName,
    this.fileSize,
    this.sizeLabel,
    this.thumbnail,
    this.isFeatured = false,
    this.order = 0,
  });

  factory TrainingResourceModel.fromJson(Map<String, dynamic> json) {
    final int? size = _asInt(json['fileSize'] ?? json['file_size']);
    final String? sizeLabel = json['sizeLabel']?.toString();
    return TrainingResourceModel(
      id: _asInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? '',
      fileUrl: (json['fileUrl'] ??
              json['file_url'] ??
              json['url'] ??
              json['mediaUrl'] ??
              json['media_url'] ??
              json['videoUrl'] ??
              json['video_url'] ??
              json['pdfUrl'] ??
              json['pdf_url'] ??
              json['path'] ??
              json['file'])
          ?.toString() ??
          '',
      fileName: (json['fileName'] ?? json['file_name'])?.toString(),
      fileSize: size,
      sizeLabel: sizeLabel,
      thumbnail: json['thumbnail']?.toString(),
      isFeatured: _asBool(
            json['isFeatured'] ??
                json['isFeaturedOnboarding'] ??
                json['is_featured_onboarding'],
          ) ??
          false,
      order: _asInt(json['order']) ?? 0,
    );
  }

  final int id;
  final String title;
  final String? description;
  final String category;
  final String fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? sizeLabel;
  final String? thumbnail;
  final bool isFeatured;
  final int order;

  TrainingResource toEntity() {
    return TrainingResource(
      id: id,
      title: title,
      description: description,
      category: category,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      sizeLabel: sizeLabel,
      thumbnail: thumbnail,
      isFeatured: isFeatured,
      order: order,
    );
  }

  static int? _asInt(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static bool? _asBool(Object? raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final String s = raw.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return null;
  }
}

class TrainingListModel {
  const TrainingListModel({
    required this.categories,
    required this.resources,
  });

  factory TrainingListModel.fromData(dynamic data) {
    if (data is! Map) {
      return const TrainingListModel(categories: <String>[], resources: <TrainingResourceModel>[]);
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    final List<String> categories = <String>[];
    final Object? cats = map['categories'];
    if (cats is List) {
      for (final Object? c in cats) {
        final String s = c?.toString().trim() ?? '';
        if (s.isNotEmpty) categories.add(s);
      }
    }
    final List<TrainingResourceModel> resources = <TrainingResourceModel>[];
    final Object? list = map['resources'] ?? map['items'] ?? map;
    if (list is List) {
      for (final Object? item in list) {
        if (item is Map) {
          resources.add(
            TrainingResourceModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return TrainingListModel(categories: categories, resources: resources);
  }

  final List<String> categories;
  final List<TrainingResourceModel> resources;

  List<TrainingResource> toEntities() =>
      resources.map((TrainingResourceModel m) => m.toEntity()).toList();
}
