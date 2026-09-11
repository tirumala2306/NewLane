import 'package:flutter/material.dart';

class TrainingResource {
  const TrainingResource({
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

  final int id;
  final String title;
  final String category;
  final String fileUrl;
  final String? description;
  final String? fileName;
  final int? fileSize;
  final String? sizeLabel;
  final String? thumbnail;
  final bool isFeatured;
  final int order;

  String get displayName {
    final String name = (fileName ?? '').trim();
    if (name.isNotEmpty && name != '.') return name;
    return title;
  }

  String get displaySize {
    final String label = (sizeLabel ?? '').trim();
    if (label.isNotEmpty && label != '0 B') return label;
    return '—';
  }

  bool get isPdf =>
      category.toLowerCase() == 'pdf' ||
      displayName.toLowerCase().endsWith('.pdf');

  bool get isVideo =>
      category.toLowerCase() == 'video' ||
      RegExp(r'\.(mp4|mov|m4v|webm)$', caseSensitive: false)
          .hasMatch(fileUrl);
}

class TrainingCategoryMeta {
  const TrainingCategoryMeta({
    required this.apiCategory,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String apiCategory;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// Fixed hub categories — match design order, always shown.
class TrainingHubCatalog {
  const TrainingHubCatalog._();

  static const List<TrainingCategoryMeta> categories = <TrainingCategoryMeta>[
    TrainingCategoryMeta(
      apiCategory: 'Video',
      title: 'Videos',
      subtitle: 'Watch training videos and tutorials',
      icon: Icons.play_circle_outline,
    ),
    TrainingCategoryMeta(
      apiCategory: '50%',
      title: '50%',
      subtitle: 'Access quick training modules',
      icon: Icons.local_fire_department_outlined,
    ),
    TrainingCategoryMeta(
      apiCategory: 'Tutorial',
      title: 'Tutorials',
      subtitle: 'Step-by-step guides and walkthroughs',
      icon: Icons.description_outlined,
    ),
    TrainingCategoryMeta(
      apiCategory: 'PDF',
      title: 'PDFs',
      subtitle: 'Download guides, checklists and more',
      icon: Icons.picture_as_pdf_outlined,
    ),
    TrainingCategoryMeta(
      apiCategory: 'Social Media Tips',
      title: 'Social Media Tips',
      subtitle: 'Learn strategies to grow your brand',
      icon: Icons.campaign_outlined,
    ),
    TrainingCategoryMeta(
      apiCategory: 'Recruiting Scripts',
      title: 'Recruiting Scripts',
      subtitle: 'Scripts and templates to recruit agents',
      icon: Icons.groups_outlined,
    ),
  ];
}
