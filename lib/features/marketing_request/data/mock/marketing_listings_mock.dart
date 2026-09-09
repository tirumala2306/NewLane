import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

class MarketingListingsMock {
  const MarketingListingsMock._();

  static const List<MarketingListing> listings = <MarketingListing>[
    MarketingListing(
      id: '1',
      address: '171 Ocean Drive, Miami, FL 33139',
      price: 7900000,
      title: 'Luxury Waterfront Home',
      imageUrl:
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400&q=80',
    ),
    MarketingListing(
      id: '2',
      address: '88 Brickell Ave, Miami, FL 33131',
      price: 2450000,
      title: 'Brickell High-Rise Residence',
      imageUrl:
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400&q=80',
    ),
    MarketingListing(
      id: '3',
      address: '420 Coral Way, Coral Gables, FL 33134',
      price: 1875000,
      title: 'Coral Gables Family Home',
      imageUrl:
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400&q=80',
    ),
  ];
}
