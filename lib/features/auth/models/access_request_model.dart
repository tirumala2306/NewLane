import 'package:newlane/features/auth/domain/entities/access_request_result.dart';

class AccessRequestModel {
  const AccessRequestModel({
    required this.requestId,
    required this.message,
  });

  factory AccessRequestModel.fromEnvelope({
    required String message,
    required dynamic data,
  }) {
    int requestId = 0;
    if (data is Map) {
      requestId = _asInt(data['requestId']);
    }

    return AccessRequestModel(requestId: requestId, message: message);
  }

  final int requestId;
  final String message;

  AccessRequestResult toEntity() {
    return AccessRequestResult(requestId: requestId, message: message);
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
