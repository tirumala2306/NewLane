/// Server status for a submitted access request.
enum AccessRequestStatusType { pending, approved, rejected, unknown }

class AccessRequestStatus {
  const AccessRequestStatus({
    required this.status,
    required this.message,
    this.rejectionReason,
  });

  final AccessRequestStatusType status;
  final String message;
  final String? rejectionReason;

  bool get isPending => status == AccessRequestStatusType.pending;
  bool get isApproved => status == AccessRequestStatusType.approved;
  bool get isRejected => status == AccessRequestStatusType.rejected;

  @override
  String toString() =>
      'AccessRequestStatus(status: $status, reason: $rejectionReason, message: $message)';
}
