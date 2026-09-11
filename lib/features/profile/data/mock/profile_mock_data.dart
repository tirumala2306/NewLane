import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';

class ProfileContactItem {
  const ProfileContactItem({
    required this.value,
    this.icon,
    this.iconAsset,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final String value;
}

class ProfileStat {
  const ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class ProfileListing {
  const ProfileListing({
    required this.imageUrl,
    required this.address,
    required this.city,
    required this.price,
  });

  final String imageUrl;
  final String address;
  final String city;
  final String price;
}

class ProfileMockData {
  const ProfileMockData._();

  static const String name = 'Sarah Johnson';
  static const String title = 'Luxury Real Estate Advisor';
  static const String office = 'NEWLANE Doral';
  static const String location = 'Miami, FL';
  static const String about =
      'Passionate about helping families find their dream homes in South Florida. '
      'Specializing in luxury waterfront properties and investment opportunities '
      'with a client-first approach.';

  static const String avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';

  static const bool isOnline = true;
  static const bool isVerified = true;

  static const List<ProfileStat> stats = <ProfileStat>[
    // Active Listings stat hidden for now.
    ProfileStat(
      icon: Icons.handshake_outlined,
      value: '124',
      label: 'Deals Closed',
    ),
    ProfileStat(
      icon: Icons.star_outline,
      value: '5.0',
      label: 'Rating',
    ),
    ProfileStat(
      icon: Icons.calendar_today_outlined,
      value: '6+',
      label: 'Years Experience',
    ),
  ];

  static const List<String> specialties = <String>[
    'Luxury Homes',
    'Investments',
    'Relocation',
    'Waterfront',
  ];

  static const List<ProfileContactItem> contacts = <ProfileContactItem>[
    ProfileContactItem(
      icon: Icons.email_outlined,
      value: 'sarah.j@newlane.com',
    ),
    ProfileContactItem(
      icon: Icons.phone_outlined,
      value: '+1 (305) 555-0142',
    ),
    ProfileContactItem(
      icon: Icons.language,
      value: 'www.sarahjohnsonrealty.com',
    ),
    ProfileContactItem(
      iconAsset: AssetConstants.instagramIcon,
      value: '@sarahj_realty',
    ),
  ];

  static const List<ProfileListing> listings = <ProfileListing>[
    ProfileListing(
      imageUrl:
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400&q=80',
      address: '1200 Brickell Ave #2401',
      city: 'Miami, FL',
      price: '\$2,450,000',
    ),
    ProfileListing(
      imageUrl:
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400&q=80',
      address: '88 Ocean Drive',
      city: 'Miami Beach, FL',
      price: '\$3,100,000',
    ),
    ProfileListing(
      imageUrl:
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&q=80',
      address: '450 Coral Way',
      city: 'Coral Gables, FL',
      price: '\$1,875,000',
    ),
  ];
}
