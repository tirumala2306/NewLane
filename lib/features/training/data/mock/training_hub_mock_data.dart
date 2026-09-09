import 'package:flutter/material.dart';

class TrainingCategory {
  const TrainingCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.progress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final double? progress;
}

class TrainingDownload {
  const TrainingDownload({
    required this.fileName,
    required this.sizeLabel,
    required this.icon,
    required this.iconColor,
  });

  final String fileName;
  final String sizeLabel;
  final IconData icon;
  final Color iconColor;
}

class TrainingHubMockData {
  const TrainingHubMockData._();

  static const String onboardingTitle = 'New Agent Onboarding';
  static const String onboardingSubtitle =
      'Watch key videos to get started with NEWLANE.';
  static const String onboardingImageUrl =
      'https://images.unsplash.com/photo-1512453979798-5ea9204c5c1b?w=1200&q=80';

  static const List<TrainingCategory> categories = <TrainingCategory>[
    TrainingCategory(
      title: 'Videos',
      subtitle: 'Watch training videos and tutorials',
      icon: Icons.play_circle_outline,
    ),
    TrainingCategory(
      title: '50%',
      subtitle: 'Access quick training modules',
      icon: Icons.local_fire_department_outlined,
      progress: 0.5,
    ),
    TrainingCategory(
      title: 'Tutorials',
      subtitle: 'Step-by-step guides and walkthroughs',
      icon: Icons.description_outlined,
    ),
    TrainingCategory(
      title: 'PDFs',
      subtitle: 'Download guides, checklists and more',
      icon: Icons.picture_as_pdf_outlined,
    ),
    TrainingCategory(
      title: 'Social Media Tips',
      subtitle: 'Learn strategies to grow your brand',
      icon: Icons.campaign_outlined,
    ),
    TrainingCategory(
      title: 'Recruiting Scripts',
      subtitle: 'Scripts and templates to recruit agents',
      icon: Icons.groups_outlined,
    ),
  ];

  static const List<TrainingDownload> downloads = <TrainingDownload>[
    TrainingDownload(
      fileName: 'Onboarding Checklist.pdf',
      sizeLabel: '1.2 MB',
      icon: Icons.picture_as_pdf,
      iconColor: Color(0xFFE53935),
    ),
    TrainingDownload(
      fileName: 'Welcome Guide.pdf',
      sizeLabel: '2.4 MB',
      icon: Icons.description,
      iconColor: Color(0xFF3B82F6),
    ),
  ];
}
