import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';

/// Listing created via Create Post (type = Listing).
class ActiveListing {
  const ActiveListing({
    required this.id,
    required this.address,
    required this.title,
    this.price = 0,
    this.imageUrl = '',
    this.city = '',
  });

  final String id;
  final String address;
  final String title;
  final int price;
  final String imageUrl;
  final String city;

  String get priceLabel {
    if (price <= 0) return '';
    final String digits = price.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return '\$$buffer';
  }

  ProfileListing toProfileListing() {
    return ProfileListing(
      imageUrl: imageUrl,
      address: address,
      city: city.isNotEmpty ? city : '—',
      price: priceLabel.isNotEmpty ? priceLabel : '—',
    );
  }

  MarketingListing toMarketingListing() {
    return MarketingListing(
      id: id,
      address: address,
      price: price > 0 ? price : 0,
      title: title.isNotEmpty ? title : 'Listing',
      status: 'Active',
      imageUrl: imageUrl,
    );
  }
}

/// Parse address / price / title from a Listing feed post caption + location.
ActiveListing activeListingFromFeedParts({
  required int postId,
  required String caption,
  required String imageUrl,
  String locationLabel = '',
  String authorName = '',
}) {
  final String text = caption.trim();
  final List<String> lines = text
      .split('\n')
      .map((String e) => e.trim())
      .where((String e) => e.isNotEmpty)
      .toList();

  final RegExp priceRe = RegExp(r'\$\s*([\d,]+)');
  int price = 0;
  final Match? priceMatch = priceRe.firstMatch(text);
  if (priceMatch != null) {
    price = int.tryParse(priceMatch.group(1)!.replaceAll(',', '')) ?? 0;
  }

  String address = locationLabel.trim();
  if (address.isEmpty) {
    // Prefer a line that looks like an address (has a digit / comma).
    for (final String line in lines) {
      if (priceRe.hasMatch(line)) continue;
      if (RegExp(r'\d').hasMatch(line) || line.contains(',')) {
        address = line;
        break;
      }
    }
  }
  if (address.isEmpty && lines.isNotEmpty) {
    address = lines.first;
  }
  if (address.isEmpty) {
    address = 'Listing #$postId';
  }

  String title = '';
  for (final String line in lines) {
    if (line == address) continue;
    if (priceRe.hasMatch(line) && line.replaceAll(priceRe, '').trim().isEmpty) {
      continue;
    }
    title = line;
    break;
  }
  if (title.isEmpty) {
    title = authorName.isNotEmpty ? '$authorName Listing' : 'Active Listing';
  }

  String city = '';
  final List<String> parts = address.split(',');
  if (parts.length >= 2) {
    city = parts.sublist(1).join(',').trim();
  }

  return ActiveListing(
    id: '$postId',
    address: address,
    title: title,
    price: price,
    imageUrl: imageUrl,
    city: city,
  );
}
