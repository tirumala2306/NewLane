import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';

enum SupportTicketStatus { submitted, inProgress, resolved }

extension SupportTicketStatusX on SupportTicketStatus {
  String get label => switch (this) {
        SupportTicketStatus.submitted => 'Submitted',
        SupportTicketStatus.inProgress => 'In Progress',
        SupportTicketStatus.resolved => 'Resolved',
      };

  Color get color => switch (this) {
        SupportTicketStatus.submitted => const Color(0xFF3B82F6),
        SupportTicketStatus.inProgress => AppColors.primaryButtonBg,
        SupportTicketStatus.resolved => const Color(0xFF4CAF50),
      };

  static SupportTicketStatus fromRaw(String? raw) {
    final String value = (raw ?? '').trim().toLowerCase().replaceAll('_', ' ');
    if (value.contains('resolve') ||
        value.contains('closed') ||
        value.contains('done') ||
        value.contains('complete')) {
      return SupportTicketStatus.resolved;
    }
    if (value.contains('progress') || value.contains('working')) {
      return SupportTicketStatus.inProgress;
    }
    return SupportTicketStatus.submitted;
  }
}

class SupportCategory {
  const SupportCategory({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class SupportTimelineEvent {
  const SupportTimelineEvent({
    required this.stage,
    required this.completed,
    required this.timestamp,
    this.message,
  });

  final SupportTicketStatus stage;
  final bool completed;
  final String timestamp;
  final String? message;
}

class SupportAttachment {
  const SupportAttachment({
    required this.name,
    required this.sizeLabel,
    this.path,
    this.url,
  });

  final String name;
  final String sizeLabel;
  final String? path;
  final String? url;
}

class SupportMessage {
  const SupportMessage({
    required this.isMine,
    required this.author,
    required this.timestamp,
    required this.text,
    this.attachment,
  });

  final bool isMine;
  final String author;
  final String timestamp;
  final String text;
  final SupportAttachment? attachment;
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.apiId,
    required this.title,
    required this.status,
    required this.updatedLabel,
    required this.submittedLabel,
    required this.timeline,
    this.category = '',
    this.description = '',
    this.messages = const <SupportMessage>[],
  });

  /// Display id (e.g. #SR-12).
  final String id;
  final int apiId;
  final String title;
  final SupportTicketStatus status;
  final String updatedLabel;
  final String submittedLabel;
  final List<SupportTimelineEvent> timeline;
  final String category;
  final String description;
  final List<SupportMessage> messages;

  String get timeAgo => updatedLabel;

  bool get isClosed => status == SupportTicketStatus.resolved;

  SupportTicket copyWith({
    SupportTicketStatus? status,
    List<SupportMessage>? messages,
    List<SupportTimelineEvent>? timeline,
    String? updatedLabel,
  }) {
    return SupportTicket(
      id: id,
      apiId: apiId,
      title: title,
      status: status ?? this.status,
      updatedLabel: updatedLabel ?? this.updatedLabel,
      submittedLabel: submittedLabel,
      timeline: timeline ?? this.timeline,
      category: category,
      description: description,
      messages: messages ?? this.messages,
    );
  }
}

class SupportMockData {
  const SupportMockData._();

  static const List<SupportCategory> categories = <SupportCategory>[
    SupportCategory(
      title: 'Marketing Support',
      description: 'Get help with marketing requests and promotional materials.',
      icon: Icons.campaign_outlined,
    ),
    SupportCategory(
      title: 'Recruiting Support',
      description: 'Assistance with recruiting, onboarding and agent resources.',
      icon: Icons.support_agent_outlined,
    ),
    SupportCategory(
      title: 'Branding Support',
      description: 'Logos, brand guidelines and approved templates.',
      icon: Icons.work_outline,
    ),
    SupportCategory(
      title: 'Tech Support',
      description: 'Help with login issues, app problems and technical questions.',
      icon: Icons.laptop_mac_outlined,
    ),
    SupportCategory(
      title: 'Ticket Support',
      description: 'Track and manage your existing support tickets.',
      icon: Icons.description_outlined,
    ),
  ];

  static const List<String> categoryOptions = <String>[
    'Ticket Support',
    'Tech Support',
    'Marketing Support',
    'Recruiting Support',
    'Branding Support',
  ];
}
