enum MarketingRequestType {
  justListed('Just Listed'),
  openHouse('Open House'),
  socialMediaPost('Social Media Post'),
  flyer('Flyer'),
  other('Other');

  const MarketingRequestType(this.label);
  final String label;

  static MarketingRequestType fromLabel(String? raw) {
    final String value = (raw ?? '').trim().toLowerCase();
    for (final MarketingRequestType type in MarketingRequestType.values) {
      if (type.label.toLowerCase() == value) return type;
      if (type.name.toLowerCase() == value.replaceAll(RegExp(r'[\s_-]+'), '')) {
        return type;
      }
    }
    if (value.contains('social')) return MarketingRequestType.socialMediaPost;
    if (value.contains('listed')) return MarketingRequestType.justListed;
    if (value.contains('open')) return MarketingRequestType.openHouse;
    if (value.contains('flyer')) return MarketingRequestType.flyer;
    return MarketingRequestType.other;
  }
}

enum MarketingRequestStatus {
  submitted,
  inProgress,
  completed;

  String get label {
    return switch (this) {
      MarketingRequestStatus.submitted => 'Submitted',
      MarketingRequestStatus.inProgress => 'In Progress',
      MarketingRequestStatus.completed => 'Completed',
    };
  }

  bool get isActive => this != MarketingRequestStatus.completed;

  static MarketingRequestStatus fromRaw(String? raw) {
    final String value = (raw ?? '').trim().toLowerCase().replaceAll('_', ' ');
    if (value.contains('complete') ||
        value.contains('done') ||
        value.contains('approved')) {
      return MarketingRequestStatus.completed;
    }
    if (value.contains('progress') || value.contains('working')) {
      return MarketingRequestStatus.inProgress;
    }
    // submitted / pending / pending review / review
    return MarketingRequestStatus.submitted;
  }
}

class MarketingListing {
  const MarketingListing({
    required this.id,
    required this.address,
    required this.price,
    required this.title,
    this.status = 'Active',
    this.imageUrl = '',
  });

  final String id;
  final String address;
  final int price;
  final String title;
  final String status;
  final String imageUrl;

  String get priceLabel {
    final String digits = price.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return '\$$buffer';
  }
}

class MarketingRequestFile {
  const MarketingRequestFile({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;
}

class MarketingRequest {
  const MarketingRequest({
    required this.id,
    required this.requestType,
    required this.listingAddress,
    required this.listingPrice,
    required this.notes,
    required this.status,
    this.listingTitle = '',
    this.thumbnailUrl = '',
    this.createdAt,
    this.mediaUrls = const <String>[],
    this.finalFiles = const <MarketingRequestFile>[],
  });

  final int id;
  final MarketingRequestType requestType;
  final String listingAddress;
  final int listingPrice;
  final String notes;
  final MarketingRequestStatus status;
  final String listingTitle;
  final String thumbnailUrl;
  final DateTime? createdAt;
  final List<String> mediaUrls;
  final List<MarketingRequestFile> finalFiles;

  String get priceLabel {
    if (listingPrice <= 0) return '';
    return MarketingListing(
      id: 'p',
      address: listingAddress,
      price: listingPrice,
      title: listingTitle,
    ).priceLabel;
  }

  String get requestedOnLabel {
    final DateTime? date = createdAt;
    if (date == null) return '';
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Requested on ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class MarketingRequestSubmitResult {
  const MarketingRequestSubmitResult({
    required this.message,
    this.request,
  });

  final String message;
  final MarketingRequest? request;
}
