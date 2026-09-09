import 'package:newlane/core/utils/media_url.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';

class SupportTicketModel {
  const SupportTicketModel({
    required this.apiId,
    required this.displayId,
    required this.title,
    required this.status,
    required this.updatedLabel,
    required this.submittedLabel,
    required this.timeline,
    this.category = '',
    this.description = '',
    this.messages = const <SupportMessage>[],
  });

  factory SupportTicketModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    final int apiId = _asInt(json['id'] ?? json['_id'] ?? json['ticketId']);
    final String number =
        (json['ticketNumber'] ?? json['number'] ?? json['code'] ?? '').toString();
    final String displayId = number.trim().isNotEmpty
        ? (number.startsWith('#') ? number : '#$number')
        : '#SR-$apiId';

    final String subject =
        (json['subject'] ?? json['title'] ?? json['summary'] ?? '').toString();
    final String description =
        (json['description'] ?? json['body'] ?? json['details'] ?? '')
            .toString();
    final SupportTicketStatus status = SupportTicketStatusX.fromRaw(
      (json['status'] ?? json['state'] ?? '').toString(),
    );
    final DateTime? createdAt = _asDate(
      json['createdAt'] ?? json['submittedAt'] ?? json['created_at'],
    );
    final DateTime? updatedAt = _asDate(
      json['updatedAt'] ?? json['updated_at'] ?? createdAt,
    );

    final List<SupportMessage> messages = _parseMessages(
      json['messages'] ?? json['replies'] ?? json['conversation'],
      currentUserId: currentUserId,
      fallbackDescription: description,
      fallbackCreatedAt: createdAt,
    );

    return SupportTicketModel(
      apiId: apiId,
      displayId: displayId,
      title: subject,
      status: status,
      category: (json['category'] ?? '').toString(),
      description: description,
      updatedLabel: updatedAt == null
          ? 'Updated recently'
          : 'Updated ${_formatDate(updatedAt)}',
      submittedLabel: createdAt == null
          ? 'Submitted recently'
          : 'Submitted ${_formatDateTime(createdAt)}',
      timeline: _buildTimeline(status, createdAt, updatedAt),
      messages: messages,
    );
  }

  final int apiId;
  final String displayId;
  final String title;
  final SupportTicketStatus status;
  final String updatedLabel;
  final String submittedLabel;
  final List<SupportTimelineEvent> timeline;
  final String category;
  final String description;
  final List<SupportMessage> messages;

  SupportTicket toEntity() {
    return SupportTicket(
      id: displayId,
      apiId: apiId,
      title: title,
      status: status,
      updatedLabel: updatedLabel,
      submittedLabel: submittedLabel,
      timeline: timeline,
      category: category,
      description: description,
      messages: messages,
    );
  }

  static List<SupportTimelineEvent> _buildTimeline(
    SupportTicketStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  ) {
    final bool inProgress =
        status == SupportTicketStatus.inProgress ||
        status == SupportTicketStatus.resolved;
    final bool resolved = status == SupportTicketStatus.resolved;
    return <SupportTimelineEvent>[
      SupportTimelineEvent(
        stage: SupportTicketStatus.submitted,
        completed: true,
        timestamp: createdAt == null ? 'Submitted' : _formatDateTime(createdAt),
        message: 'Your request has been submitted successfully.',
      ),
      SupportTimelineEvent(
        stage: SupportTicketStatus.inProgress,
        completed: inProgress,
        timestamp: inProgress
            ? (updatedAt == null ? 'In progress' : _formatDateTime(updatedAt))
            : 'Pending',
        message: inProgress ? 'Our team is working on your request.' : null,
      ),
      SupportTimelineEvent(
        stage: SupportTicketStatus.resolved,
        completed: resolved,
        timestamp: resolved
            ? (updatedAt == null ? 'Resolved' : _formatDateTime(updatedAt))
            : 'Pending',
        message: resolved ? 'This request has been resolved.' : null,
      ),
    ];
  }

  static List<SupportMessage> _parseMessages(
    dynamic raw, {
    int? currentUserId,
    String fallbackDescription = '',
    DateTime? fallbackCreatedAt,
  }) {
    if (raw is! List || raw.isEmpty) {
      if (fallbackDescription.trim().isEmpty) return const <SupportMessage>[];
      return <SupportMessage>[
        SupportMessage(
          isMine: true,
          author: 'You',
          timestamp: fallbackCreatedAt == null
              ? 'Just now'
              : _formatDateTime(fallbackCreatedAt),
          text: fallbackDescription.trim(),
        ),
      ];
    }

    return raw
        .whereType<Map>()
        .map((Map item) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item);
          final Object? authorRaw =
              map['author'] ?? map['user'] ?? map['agent'] ?? map['sender'];
          final Map<String, dynamic> author = authorRaw is Map
              ? Map<String, dynamic>.from(authorRaw)
              : <String, dynamic>{};
          final int senderId = _asInt(
            map['senderId'] ??
                map['userId'] ??
                map['authorId'] ??
                author['id'],
          );
          final bool isMine = map['isMine'] == true ||
              map['fromMe'] == true ||
              (currentUserId != null &&
                  senderId > 0 &&
                  senderId == currentUserId) ||
              (map['role']?.toString().toLowerCase() == 'agent' &&
                  map['isSupport'] != true) ||
              map['isStaff'] == false;
          final bool staff = map['isStaff'] == true ||
              map['isSupport'] == true ||
              (map['role']?.toString().toLowerCase().contains('support') ??
                  false) ||
              (map['role']?.toString().toLowerCase().contains('admin') ?? false);

          final String authorName =
              (map['authorName'] ??
                      author['fullName'] ??
                      author['name'] ??
                      (staff ? 'Support Team' : (isMine ? 'You' : 'Agent')))
                  .toString();
          final DateTime? at = _asDate(map['createdAt'] ?? map['created_at']);
          final Object? attachmentRaw =
              map['attachment'] ?? map['attachments'] ?? map['file'];
          SupportAttachment? attachment;
          if (attachmentRaw is Map) {
            final Map<String, dynamic> a =
                Map<String, dynamic>.from(attachmentRaw);
            final String url =
                resolveMediaUrl((a['url'] ?? a['path'] ?? '').toString()) ?? '';
            attachment = SupportAttachment(
              name: (a['name'] ?? a['fileName'] ?? 'Attachment').toString(),
              sizeLabel: (a['sizeLabel'] ?? a['size'] ?? '').toString(),
              url: url.isEmpty ? null : url,
            );
          } else if (attachmentRaw is List && attachmentRaw.isNotEmpty) {
            final Object? first = attachmentRaw.first;
            if (first is Map) {
              final Map<String, dynamic> a =
                  Map<String, dynamic>.from(first);
              final String url =
                  resolveMediaUrl((a['url'] ?? a['path'] ?? '').toString()) ??
                      '';
              attachment = SupportAttachment(
                name: (a['name'] ?? a['fileName'] ?? 'Attachment').toString(),
                sizeLabel: (a['sizeLabel'] ?? a['size'] ?? '').toString(),
                url: url.isEmpty ? null : url,
              );
            }
          }

          return SupportMessage(
            isMine: staff ? false : isMine,
            author: staff ? 'Support Team' : authorName,
            timestamp: at == null ? '' : _formatDateTime(at),
            text: (map['message'] ??
                    map['text'] ??
                    map['body'] ??
                    map['content'] ??
                    '')
                .toString(),
            attachment: attachment,
          );
        })
        .where((SupportMessage m) => m.text.trim().isNotEmpty)
        .toList();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value'.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _formatDateTime(DateTime date) {
    final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(date)} at $hour:$minute $period';
  }
}

class SupportTicketListModel {
  const SupportTicketListModel({required this.tickets});

  factory SupportTicketListModel.fromEnvelope(
    dynamic data, {
    int? currentUserId,
  }) {
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? raw =
          map['tickets'] ?? map['items'] ?? map['data'] ?? map['results'];
      list = raw is List ? raw : const <dynamic>[];
    } else {
      list = const <dynamic>[];
    }

    return SupportTicketListModel(
      tickets: list
          .whereType<Map>()
          .map(
            (Map item) => SupportTicketModel.fromJson(
              Map<String, dynamic>.from(item),
              currentUserId: currentUserId,
            ),
          )
          .toList(),
    );
  }

  final List<SupportTicketModel> tickets;

  List<SupportTicket> toEntities() =>
      tickets.map((SupportTicketModel e) => e.toEntity()).toList();
}
