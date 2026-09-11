import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';

class HomeAnnouncement {
  const HomeAnnouncement({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.thumbnailUrl,
    this.timeLabel,
    this.showUnreadDot = false,
    this.id,
    this.kind,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? thumbnailUrl;
  final String? timeLabel;
  final bool showUnreadDot;
  final int? id;
  final String? kind;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.title,
    required this.subtitle,
    this.icon,
    this.assetIcon,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? assetIcon;
}

class HomeRequestStat {
  const HomeRequestStat({
    required this.count,
    required this.label,
    required this.icon,
  });

  final int count;
  final String label;
  final IconData icon;
}

class HomeFeedPost {
  const HomeFeedPost({
    required this.authorName,
    required this.officeLabel,
    required this.timeAgo,
    required this.caption,
    required this.avatarUrl,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });

  final String authorName;
  final String officeLabel;
  final String timeAgo;
  final String caption;
  final String avatarUrl;
  final String imageUrl;
  final int likes;
  final int comments;
}

class HomeMockData {
  const HomeMockData._();

  static const String officeName = 'NEWLANE Brickell';

  static const List<HomeAnnouncement> announcements = <HomeAnnouncement>[
    HomeAnnouncement(
      title: 'Team Meeting Today',
      subtitle: "Friday at 10:00 AM. Don't miss it!",
      icon: Icons.calendar_today_outlined,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=200&q=80',
    ),
    HomeAnnouncement(
      title: 'New Agent Joined',
      subtitle: 'Welcome, Jessica Williams to the team!',
      icon: Icons.person_add_alt_1_outlined,
      timeLabel: 'Yesterday',
      showUnreadDot: true,
    ),
    HomeAnnouncement(
      title: 'Training Video Uploaded',
      subtitle: "'Client Consultation Best Practices' is now live.",
      icon: Icons.videocam_outlined,
      timeLabel: 'May 20',
      showUnreadDot: true,
    ),
  ];

  static const List<HomeQuickAction> quickActions = <HomeQuickAction>[
    HomeQuickAction(
      title: 'Chat',
      subtitle: 'Connect with your team',
      assetIcon: AssetConstants.chatIcon,
    ),
    HomeQuickAction(
      title: 'Marketing Request',
      subtitle: 'Submit & track requests',
      icon: Icons.campaign_outlined,
    ),
    HomeQuickAction(
      title: 'Training Hub',
      subtitle: 'Learn, grow & stay updated',
      icon: Icons.school_outlined,
    ),
    HomeQuickAction(
      title: 'Directory',
      subtitle: 'Find & connect with agents',
      assetIcon: AssetConstants.personalIcon,
    ),
    HomeQuickAction(
      title: 'Content Generator',
      subtitle: 'Create engaging content',
      icon: Icons.auto_awesome,
    ),
  ];

  static const List<HomeRequestStat> requestStats = <HomeRequestStat>[
    HomeRequestStat(
      count: 0,
      label: 'In Progress',
      icon: Icons.timelapse_outlined,
    ),
    HomeRequestStat(
      count: 0,
      label: 'Completed',
      icon: Icons.check_circle_outline,
    ),
    HomeRequestStat(
      count: 0,
      label: 'Pending Review',
      icon: Icons.schedule_outlined,
    ),
  ];

  static const HomeFeedPost feedPost = HomeFeedPost(
    authorName: 'Alejandra M.',
    officeLabel: 'NEWLANE Doral',
    timeAgo: '2h ago',
    caption:
        'Just closed another happy transaction! Grateful for my amazing clients.',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&q=80',
    imageUrl:
        'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=800&q=80',
    likes: 24,
    comments: 6,
  );
}
