import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';

enum ContentGeneratorType {
  socialMediaPost,
  propertyDescription,
  emailCopy,
  listingContent,
  marketingIdeas,
  others,
}

extension ContentGeneratorTypeX on ContentGeneratorType {
  String get title => switch (this) {
        ContentGeneratorType.socialMediaPost => 'Social Media Post',
        ContentGeneratorType.propertyDescription => 'Property Description',
        ContentGeneratorType.emailCopy => 'Email Copy',
        ContentGeneratorType.listingContent => 'Listing Content',
        ContentGeneratorType.marketingIdeas => 'Marketing Ideas',
        ContentGeneratorType.others => 'Others',
      };

  String get subtitle => switch (this) {
        ContentGeneratorType.socialMediaPost =>
          'Create engaging social media content',
        ContentGeneratorType.propertyDescription =>
          'Write compelling property descriptions',
        ContentGeneratorType.emailCopy => 'Create professional email content',
        ContentGeneratorType.listingContent =>
          'Generate listing details and highlights',
        ContentGeneratorType.marketingIdeas => 'Get fresh marketing ideas',
        ContentGeneratorType.others => 'Custom content for your needs',
      };

  IconData? get icon => switch (this) {
        ContentGeneratorType.socialMediaPost => null,
        ContentGeneratorType.propertyDescription => Icons.home_outlined,
        ContentGeneratorType.emailCopy => Icons.mail_outline,
        ContentGeneratorType.listingContent => Icons.description_outlined,
        ContentGeneratorType.marketingIdeas => Icons.lightbulb_outline,
        ContentGeneratorType.others => Icons.more_horiz,
      };

  String? get assetIcon => switch (this) {
        ContentGeneratorType.socialMediaPost => AssetConstants.instagramIcon,
        _ => null,
      };

  bool get showsPlatform => this == ContentGeneratorType.socialMediaPost;
}

class ContentGeneratorDraft {
  const ContentGeneratorDraft({
    required this.type,
    this.topic = '',
    this.keyDetails = '',
    this.tone = 'Professional',
    this.platform = 'Instagram',
    this.notes = '',
    this.generatedText = '',
  });

  final ContentGeneratorType type;
  final String topic;
  final String keyDetails;
  final String tone;
  final String platform;
  final String notes;
  final String generatedText;

  static ContentGeneratorDraft fromExtra(Object? extra) {
    if (extra is ContentGeneratorDraft) {
      return extra;
    }
    return const ContentGeneratorDraft(
      type: ContentGeneratorType.socialMediaPost,
    );
  }

  ContentGeneratorDraft copyWith({
    ContentGeneratorType? type,
    String? topic,
    String? keyDetails,
    String? tone,
    String? platform,
    String? notes,
    String? generatedText,
  }) {
    return ContentGeneratorDraft(
      type: type ?? this.type,
      topic: topic ?? this.topic,
      keyDetails: keyDetails ?? this.keyDetails,
      tone: tone ?? this.tone,
      platform: platform ?? this.platform,
      notes: notes ?? this.notes,
      generatedText: generatedText ?? this.generatedText,
    );
  }
}

class ContentEditResult {
  const ContentEditResult({
    required this.draft,
    this.regenerate = false,
  });

  final ContentGeneratorDraft draft;
  final bool regenerate;
}
