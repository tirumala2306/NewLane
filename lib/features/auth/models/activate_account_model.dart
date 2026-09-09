import 'package:newlane/features/auth/domain/entities/activate_account_result.dart';

class ActivateAccountModel {
  const ActivateAccountModel({
    required this.token,
    required this.message,
  });

  factory ActivateAccountModel.fromEnvelope({
    required String message,
    required dynamic data,
  }) {
    String token = '';

    if (data is Map) {
      token = data['token']?.toString() ?? '';
    }

    return ActivateAccountModel(token: token, message: message);
  }

  final String token;
  final String message;

  ActivateAccountResult toEntity() {
    return ActivateAccountResult(token: token, message: message);
  }
}
