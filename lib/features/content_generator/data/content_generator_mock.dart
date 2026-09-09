import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';

class ContentGeneratorMock {
  const ContentGeneratorMock._();

  static const List<String> tones = <String>[
    'Professional',
    'Friendly',
    'Luxury',
    'Bold',
    'Warm',
  ];

  static const List<String> platforms = <String>[
    'Instagram',
    'Facebook',
    'LinkedIn',
    'X',
  ];

  static const String previewImageUrl =
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200&q=80';

  static const String flyerImageUrl =
      'https://images.unsplash.com/photo-1600596542813-85e6f6f0d8c2?w=1200&q=80';

  static const String defaultHeadline = 'Modern Living in Brickell';
  static const String defaultLocation = 'Brickell, Miami, FL';
  static const String flyerAddress = '171 OCEAN DRIVE';
  static const String flyerCity = 'MIAMI, FL 33139';
  static const String flyerPrice = '\$7,900,000';
  static const String flyerTagline = 'Luxury Waterfront Living';

  static const int beds = 3;
  static const int baths = 2;
  static const String sqft = '2,100';

  static const int flyerBeds = 5;
  static const String flyerBaths = '5.5';
  static const String flyerSqft = '4,800';

  static const String defaultPostText =
      'Just Listed.\n'
      'Modern living in the heart of Brickell.\n\n'
      'This stunning 3 bed, 2 bath home offers 2,100 sq ft of stylish living space, premium finishes, and unbeatable location.\n\n'
      '📍 Brickell, Miami, FL\n\n'
      '#JustListed #Brickell #LuxuryLiving #NewLane #MiamiRealEstate';

  static String buildGeneratedText(ContentGeneratorDraft draft) {
    final String topic = draft.topic.trim();
    if (topic.isEmpty) {
      return defaultPostText;
    }

    final String details = draft.keyDetails.trim();
    final String extra = details.isEmpty
        ? 'This stunning 3 bed, 2 bath home offers 2,100 sq ft of stylish living space, premium finishes, and unbeatable location.'
        : details;

    return 'Just Listed.\n'
        '$topic\n\n'
        '$extra\n\n'
        '📍 Brickell, Miami, FL\n\n'
        '#JustListed #Brickell #LuxuryLiving #NewLane #MiamiRealEstate';
  }

  static List<String> captionOptions(ContentGeneratorDraft draft) {
    final String topic = draft.topic.trim().isEmpty
        ? 'Modern living in the heart of Brickell'
        : draft.topic.trim();
    return <String>[
      defaultPostText,
      'Now on the market: $topic. Schedule a private showing today. #NEWLANE #JustListed',
      'Your next chapter starts here. $topic — reach out to tour this home. #MiamiRealEstate',
    ];
  }

  static String headlineFor(ContentGeneratorDraft draft) {
    final String topic = draft.topic.trim();
    return topic.isEmpty ? defaultHeadline : topic;
  }
}
