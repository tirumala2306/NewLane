import 'package:flutter/material.dart';

enum CreatePostType { win, listing, event, update }

enum CreateShareTo { all, office, team, private }

class CreatePostOption {
  const CreatePostOption({
    required this.label,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final IconData icon;
  final String? subtitle;
}

class CreatePostMockData {
  const CreatePostMockData._();

  static const String officeName = 'NEWLANE Brickell';
  static const String location = 'Miami, FL';
  static const int maxCaptionLength = 500;
  static const int maxMediaCount = 10;

  static const List<(CreatePostType, CreatePostOption)> postTypes =
      <(CreatePostType, CreatePostOption)>[
        (
          CreatePostType.win,
          CreatePostOption(label: 'Win', icon: Icons.emoji_events_outlined),
        ),
        (
          CreatePostType.listing,
          CreatePostOption(label: 'Listing', icon: Icons.home_outlined),
        ),
        (
          CreatePostType.event,
          CreatePostOption(label: 'Event', icon: Icons.calendar_today_outlined),
        ),
        (
          CreatePostType.update,
          CreatePostOption(label: 'Update', icon: Icons.campaign_outlined),
        ),
      ];

  static const List<(CreateShareTo, CreatePostOption)> shareToOptions =
      <(CreateShareTo, CreatePostOption)>[
        (
          CreateShareTo.all,
          CreatePostOption(label: 'All', icon: Icons.public),
        ),
        (
          CreateShareTo.office,
          CreatePostOption(
            label: 'Office',
            icon: Icons.apartment_outlined,
            subtitle: 'Brickell',
          ),
        ),
        (
          CreateShareTo.team,
          CreatePostOption(
            label: 'Team',
            icon: Icons.groups_outlined,
            subtitle: '5 Members',
          ),
        ),
        (
          CreateShareTo.private,
          CreatePostOption(
            label: 'Private',
            icon: Icons.lock_outline,
            subtitle: 'Only me',
          ),
        ),
      ];
}
