import 'package:newlane/features/auth/domain/entities/access_request_status.dart';

class AccessRequestStatusModel {
  const AccessRequestStatusModel({
    required this.status,
    required this.message,
    this.rejectionReason,
  });

  factory AccessRequestStatusModel.fromEnvelope({
    required String message,
    required dynamic data,
  }) {
    String rawStatus = 'unknown';
    String? reason;

    if (data is Map) {
      rawStatus = data['status']?.toString() ?? 'unknown';
      final Object? reasonRaw = data['rejectionReason'];
      if (reasonRaw != null && reasonRaw.toString().trim().isNotEmpty) {
        reason = reasonRaw.toString();
      }
    }

    return AccessRequestStatusModel(
      status: _parseStatus(rawStatus),
      message: message,
      rejectionReason: reason,
    );
  }

  final AccessRequestStatusType status;
  final String message;
  final String? rejectionReason;

  AccessRequestStatus toEntity() {
    return AccessRequestStatus(
      status: status,
      message: message,
      rejectionReason: rejectionReason,
    );
  }

  @override
  String toString() =>
      'AccessRequestStatusModel(status: $status, reason: $rejectionReason, message: $message)';

  static AccessRequestStatusType _parseStatus(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'pending':
      case 'under_review':
      case 'under-review':
        return AccessRequestStatusType.pending;
      case 'approved':
      case 'accepted':
        return AccessRequestStatusType.approved;
      case 'rejected':
      case 'declined':
        return AccessRequestStatusType.rejected;
      default:
        return AccessRequestStatusType.unknown;
    }
  }
}
