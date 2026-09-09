/// Domain result after submitting an access request.
class AccessRequestResult {
  const AccessRequestResult({
    required this.requestId,
    required this.message,
  });

  final int requestId;
  final String message;

  @override
  String toString() =>
      'AccessRequestResult(requestId: $requestId, message: $message)';
}
