/// Shared API wrapper: `{ success, message, data }`.
class ApiEnvelope {
  const ApiEnvelope({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiEnvelope.from(dynamic raw) {
    if (raw is! Map) {
      return const ApiEnvelope(
        success: false,
        message: 'Unexpected response from server.',
      );
    }

    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final Object? successRaw = json['success'];

    return ApiEnvelope(
      success: successRaw == true || successRaw == 1 || successRaw == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'],
    );
  }

  final bool success;
  final String message;
  final dynamic data;
}
