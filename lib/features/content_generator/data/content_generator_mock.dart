class ContentGeneratorMock {
  const ContentGeneratorMock._();

  static const List<String> tones = <String>[
    'Professional',
    'Friendly',
    'Luxury',
    'Bold',
    'Warm',
  ];

  static const List<String> postTypes = <String>[
    'Listing',
    'Open House',
    'Just Sold',
    'Coming Soon',
  ];

  static const List<String> suggestedFeatures = <String>[
    'Waterfront',
    '4 Bedrooms',
    '5 Bathrooms',
    'Private Pool',
    'Modern Design',
  ];

  static const String fallbackImageUrl =
      'https://images.unsplash.com/photo-1600596542813-85e6f6f0d8c2?w=1200&q=80';
}
