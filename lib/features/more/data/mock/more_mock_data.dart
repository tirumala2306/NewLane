import 'package:flutter/material.dart';

enum MoreMenuId {
  profile,
  office,
  notifications,
  account,
  privacy,
  security,
  pushNotifications,
  helpSupport,
  terms,
  about,
  logout,
}

class MoreMenuItem {
  const MoreMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailingText,
    this.isDestructive = false,
  });

  final MoreMenuId id;
  final String title;
  final IconData icon;
  final String? subtitle;
  final String? trailingText;
  final bool isDestructive;
}

class MoreMockData {
  const MoreMockData._();

  static const String officeName = 'NEWLANE Brickell';
  static const String officeAddress =
      '1395 Brickell Ave, Suite 800 Miami, FL 33131';
  static const String officePhone = '(305) 555-0128';
  static const String officeEmail = 'brickell@newlane.com';
  static const int points = 1250;
  static const String supportPhone = '(305) 555-0199';
  static const String supportHours =
      'Monday - Friday 9:00 AM - 6:00 PM EST';

  static const List<MoreMenuItem> items = <MoreMenuItem>[
    MoreMenuItem(
      id: MoreMenuId.profile,
      title: 'Edit Profile',
      icon: Icons.manage_accounts_outlined,
      subtitle: 'Update your profile information',
    ),
    MoreMenuItem(
      id: MoreMenuId.office,
      title: 'Office',
      icon: Icons.apartment_sharp,
      subtitle: officeName,
    ),
    MoreMenuItem(
      id: MoreMenuId.notifications,
      title: 'Notifications',
      icon: Icons.notifications_none_outlined,
      subtitle: 'Notification history',
    ),
    MoreMenuItem(
      id: MoreMenuId.account,
      title: 'Account',
      icon: Icons.account_circle_outlined,
      subtitle: 'Account information and settings',
    ),
    MoreMenuItem(
      id: MoreMenuId.privacy,
      title: 'Privacy',
      icon: Icons.verified_user_outlined,
      subtitle: 'Privacy information and settings',
    ),
    MoreMenuItem(
      id: MoreMenuId.security,
      title: 'Security',
      icon: Icons.security_outlined,
      subtitle: 'Password and security settings',
    ),
    MoreMenuItem(
      id: MoreMenuId.pushNotifications,
      title: 'Push Notifications',
      icon: Icons.mark_chat_unread_outlined,
      subtitle: 'Manage your push notifications',
    ),
    MoreMenuItem(
      id: MoreMenuId.helpSupport,
      title: 'Help & Support',
      icon: Icons.support_agent_outlined,
      subtitle: 'Get help and support',
    ),
    MoreMenuItem(
      id: MoreMenuId.terms,
      title: 'Terms & Conditions',
      icon: Icons.description_outlined,
      subtitle: 'View terms and conditions',
    ),
    MoreMenuItem(
      id: MoreMenuId.about,
      title: 'About NewLane',
      icon: Icons.info_outline,
      subtitle: 'App information and version',
    ),
    MoreMenuItem(
      id: MoreMenuId.logout,
      title: 'Logout',
      icon: Icons.logout,
      isDestructive: true,
    ),
  ];
}

class MoreNotificationItem {
  const MoreNotificationItem({
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.icon,
    this.isUnread = false,
  });

  final String title;
  final String description;
  final String timeLabel;
  final IconData icon;
  final bool isUnread;
}

class MoreNotificationsMock {
  const MoreNotificationsMock._();

  static const List<MoreNotificationItem> items = <MoreNotificationItem>[
    MoreNotificationItem(
      title: 'Office Announcement',
      description: 'Team meeting scheduled for Friday at 10 AM.',
      timeLabel: '10:24 AM',
      icon: Icons.campaign_outlined,
      isUnread: true,
    ),
    MoreNotificationItem(
      title: 'New Message',
      description: 'Jessica sent you a message about the listing.',
      timeLabel: '9:12 AM',
      icon: Icons.mail_outline,
      isUnread: true,
    ),
    MoreNotificationItem(
      title: 'Marketing Request Update',
      description: 'Your Social Media Post request is In Progress.',
      timeLabel: 'Yesterday',
      icon: Icons.assignment_outlined,
    ),
    MoreNotificationItem(
      title: 'Training Available',
      description: 'New Agent Onboarding videos are ready to watch.',
      timeLabel: '2d ago',
      icon: Icons.school_outlined,
      isUnread: true,
    ),
    MoreNotificationItem(
      title: 'Profile Reminder',
      description: 'Complete your specialties to improve visibility.',
      timeLabel: '3d ago',
      icon: Icons.person_outline,
    ),
  ];
}
