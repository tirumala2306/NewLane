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
  });

  final String name;
  final String sizeLabel;
  final String? path;
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
    required this.title,
    required this.status,
    required this.updatedLabel,
    required this.submittedLabel,
    required this.timeline,
    this.messages = const <SupportMessage>[],
  });

  final String id;
  final String title;
  final SupportTicketStatus status;
  final String updatedLabel;
  final String submittedLabel;
  final List<SupportTimelineEvent> timeline;
  final List<SupportMessage> messages;

  String get timeAgo => updatedLabel;

  bool get isClosed => status == SupportTicketStatus.resolved;

  SupportTicket copyWith({
    SupportTicketStatus? status,
    List<SupportMessage>? messages,
    List<SupportTimelineEvent>? timeline,
  }) {
    return SupportTicket(
      id: id,
      title: title,
      status: status ?? this.status,
      updatedLabel: updatedLabel,
      submittedLabel: submittedLabel,
      timeline: timeline ?? this.timeline,
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

  static const List<SupportTicket> tickets = <SupportTicket>[
    SupportTicket(
      id: '#SR-2025-000123',
      title: 'Unable to update my profile photo',
      status: SupportTicketStatus.inProgress,
      updatedLabel: 'Updated May 12, 2025',
      submittedLabel: 'Submitted May 12, 2025 at 10:30 AM',
      timeline: <SupportTimelineEvent>[
        SupportTimelineEvent(
          stage: SupportTicketStatus.submitted,
          completed: true,
          timestamp: 'May 12, 2025 at 10:30 AM',
          message: 'Your request has been submitted successfully.',
        ),
        SupportTimelineEvent(
          stage: SupportTicketStatus.inProgress,
          completed: true,
          timestamp: 'May 12, 2025 at 11:15 AM',
          message: 'Our team is working on your request.',
        ),
        SupportTimelineEvent(
          stage: SupportTicketStatus.resolved,
          completed: false,
          timestamp: 'Pending',
        ),
      ],
      messages: <SupportMessage>[
        SupportMessage(
          isMine: true,
          author: 'You',
          timestamp: 'May 12, 2025 at 10:30 AM',
          text:
              'Hi, I am unable to update my profile photo. The upload fails every time I try.',
          attachment: SupportAttachment(
            name: 'Screenshot_2025.png',
            sizeLabel: '1.2 MB',
          ),
        ),
        SupportMessage(
          isMine: false,
          author: 'Support Team',
          timestamp: 'May 12, 2025 at 11:15 AM',
          text:
              'Thanks for reporting this. We are looking into the photo upload issue and will update you shortly.',
        ),
      ],
    ),
    SupportTicket(
      id: '#SR-2025-000124',
      title: 'Request to change office assignment',
      status: SupportTicketStatus.submitted,
      updatedLabel: 'Updated May 11, 2025',
      submittedLabel: 'Submitted May 11, 2025 at 02:10 PM',
      timeline: <SupportTimelineEvent>[
        SupportTimelineEvent(
          stage: SupportTicketStatus.submitted,
          completed: true,
          timestamp: 'May 11, 2025 at 02:10 PM',
          message: 'Your request has been submitted successfully.',
        ),
        SupportTimelineEvent(
          stage: SupportTicketStatus.inProgress,
          completed: false,
          timestamp: 'Pending',
        ),
        SupportTimelineEvent(
          stage: SupportTicketStatus.resolved,
          completed: false,
          timestamp: 'Pending',
        ),
      ],
      messages: <SupportMessage>[
        SupportMessage(
          isMine: true,
          author: 'You',
          timestamp: 'May 11, 2025 at 02:10 PM',
          text: 'Please help me change my office assignment to NEWLANE Doral.',
        ),
      ],
    ),
    SupportTicket(
      id: '#SR-2025-000121',
      title: 'How to add a new listing?',
      status: SupportTicketStatus.resolved,
      updatedLabel: 'Updated May 10, 2025',
      submittedLabel: 'Submitted May 10, 2025 at 09:15 AM',
      timeline: <SupportTimelineEvent>[
        SupportTimelineEvent(
          stage: SupportTicketStatus.submitted,
          completed: true,
          timestamp: 'May 10, 2025 at 09:15 AM',
        ),
        SupportTimelineEvent(
          stage: SupportTicketStatus.inProgress,
          completed: true,
          timestamp: 'May 10, 2025 at 09:45 AM',
        ),
        SupportTimelineEvent(
          stage: SupportTicketStatus.resolved,
          completed: true,
          timestamp: 'May 10, 2025 at 03:20 PM',
          message: 'This request has been resolved.',
        ),
      ],
      messages: <SupportMessage>[
        SupportMessage(
          isMine: true,
          author: 'You',
          timestamp: 'May 10, 2025 at 09:15 AM',
          text:
              "Hi, I need help on how to add a new listing to my account. I couldn't find the option.",
          attachment: SupportAttachment(
            name: 'Screenshot_2025...',
            sizeLabel: '120 KB',
          ),
        ),
        SupportMessage(
          isMine: false,
          author: 'Support Team',
          timestamp: 'May 10, 2025 at 09:45 AM',
          text:
              "Hello Sarah, You can add a new listing by tapping on the 'Add Listing' button from your Listings page. Please let us know if you need further assistance.",
        ),
        SupportMessage(
          isMine: true,
          author: 'You',
          timestamp: 'May 10, 2025 at 10:05 AM',
          text: 'Thank you! That helped.',
        ),
      ],
    ),
  ];

  static List<SupportTicket> get recentTickets => tickets.take(1).toList();
}

class SupportTicketStore extends ChangeNotifier {
  SupportTicketStore._()
      : _tickets = List<SupportTicket>.from(SupportMockData.tickets);

  static final SupportTicketStore instance = SupportTicketStore._();

  final List<SupportTicket> _tickets;

  List<SupportTicket> get tickets => List<SupportTicket>.unmodifiable(_tickets);

  void add(SupportTicket ticket) {
    _tickets.insert(0, ticket);
    notifyListeners();
  }

  void addMessage(String ticketId, SupportMessage message) {
    final int index = _tickets.indexWhere(
      (SupportTicket ticket) => ticket.id == ticketId,
    );
    if (index < 0) {
      return;
    }
    final SupportTicket current = _tickets[index];
    _tickets[index] = current.copyWith(
      messages: <SupportMessage>[...current.messages, message],
    );
    notifyListeners();
  }

  SupportTicket? byId(String id) {
    for (final SupportTicket ticket in _tickets) {
      if (ticket.id == id) {
        return ticket;
      }
    }
    return null;
  }
}
