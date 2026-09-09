import 'package:newlane/features/auth/domain/entities/login_result.dart';

class LoginModel {
  const LoginModel({
    required this.token,
    required this.message,
    required this.status,
    this.fullName = '',
    this.email = '',
  });

  factory LoginModel.fromEnvelope({
    required String message,
    required dynamic data,
  }) {
    String token = '';
    String status = '';
    String fullName = '';
    String email = '';

    if (data is Map) {
      token = data['token']?.toString() ?? '';
      final Object? userRaw = data['user'];
      if (userRaw is Map) {
        status = userRaw['status']?.toString() ?? '';
        fullName = userRaw['fullName']?.toString() ?? '';
        email = userRaw['email']?.toString() ?? '';
      }
    }

    return LoginModel(
      token: token,
      message: message,
      status: status,
      fullName: fullName,
      email: email,
    );
  }

  final String token;
  final String message;
  final String status;
  final String fullName;
  final String email;

  LoginResult toEntity() {
    return LoginResult(
      token: token,
      message: message,
      status: status,
      fullName: fullName,
      email: email,
    );
  }
}
