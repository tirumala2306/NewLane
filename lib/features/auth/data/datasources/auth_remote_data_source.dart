import 'package:dio/dio.dart';
import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/models/access_request_model.dart';
import 'package:newlane/features/auth/models/access_request_status_model.dart';
import 'package:newlane/features/auth/models/activate_account_model.dart';
import 'package:newlane/features/auth/models/agent_profile_model.dart';
import 'package:newlane/features/auth/models/complete_profile_model.dart';
import 'package:newlane/features/auth/models/login_model.dart';

abstract class AuthRemoteDataSource {
  Future<AccessRequestModel> submitAccessRequest({
    required String fullName,
    required String workEmail,
    required String brokerageName,
    required String phone,
  });

  Future<AccessRequestStatusModel> getAccessRequestStatus(int requestId);

  Future<ActivateAccountModel> activateAccount({
    required String activationToken,
    required String password,
    required String confirmPassword,
  });

  Future<LoginModel> login({
    required String email,
    required String password,
  });

  Future<String> forgotPassword({required String email});

  Future<String> resetPassword({
    required String resetToken,
    required String password,
  });

  Future<AgentProfileModel> getAgentMe();

  Future<void> uploadAvatar(String filePath);

  Future<CompleteProfileModel> completeProfile({
    required String fullName,
    required String phone,
    required String jobTitle,
    required String bio,
    String instagram = '',
    String website = '',
    List<String> specialties = const <String>[],
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AccessRequestModel> submitAccessRequest({
    required String fullName,
    required String workEmail,
    required String brokerageName,
    required String phone,
  }) async {
    final Map<String, String> body = <String, String>{
      'fullName': fullName,
      'workEmail': workEmail,
      'brokerageName': brokerageName,
      'phone': phone,
    };

    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.accessRequests}');

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.accessRequests,
      data: body,
    );

    final envelope = _requireSuccess(response.data, response.statusCode);

    return AccessRequestModel.fromEnvelope(
      message: envelope.message,
      data: envelope.data,
    );
  }

  @override
  Future<AccessRequestStatusModel> getAccessRequestStatus(int requestId) async {
    final String path = ApiEndpoints.accessRequestStatus(requestId);
    AppLog.line('[DATA SOURCE] GET $path');

    final response = await _apiClient.get<dynamic>(path);
    final envelope = _requireSuccess(response.data, response.statusCode);

    return AccessRequestStatusModel.fromEnvelope(
      message: envelope.message,
      data: envelope.data,
    );
  }

  @override
  Future<ActivateAccountModel> activateAccount({
    required String activationToken,
    required String password,
    required String confirmPassword,
  }) async {
    final String path = ApiEndpoints.activateAccount(activationToken);
    AppLog.line('[DATA SOURCE] POST $path');

    final response = await _apiClient.post<dynamic>(
      path,
      data: <String, String>{
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    final envelope = _requireSuccess(response.data, response.statusCode);

    return ActivateAccountModel.fromEnvelope(
      message: envelope.message,
      data: envelope.data,
    );
  }

  @override
  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.login}');

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.login,
      data: <String, String>{
        'email': email,
        'password': password,
      },
    );

    final envelope = _requireSuccess(response.data, response.statusCode);
    return LoginModel.fromEnvelope(
      message: envelope.message,
      data: envelope.data,
    );
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.forgotPassword}');

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.forgotPassword,
      data: <String, String>{'email': email},
    );

    final envelope = _requireSuccess(response.data, response.statusCode);
    return envelope.message.isEmpty
        ? 'If that email exists, a reset link has been sent.'
        : envelope.message;
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    final String path = ApiEndpoints.resetPassword(resetToken);
    AppLog.line('[DATA SOURCE] POST $path');

    final response = await _apiClient.post<dynamic>(
      path,
      data: <String, String>{
        'password': password,
      },
    );

    final envelope = _requireSuccess(response.data, response.statusCode);
    return envelope.message.isEmpty
        ? 'Your password has been reset successfully.'
        : envelope.message;
  }

  @override
  Future<AgentProfileModel> getAgentMe() async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.agentMe}');
    final response = await _apiClient.get<dynamic>(ApiEndpoints.agentMe);
    final envelope = _requireSuccess(response.data, response.statusCode);
    return AgentProfileModel.fromEnvelope(data: envelope.data);
  }

  @override
  Future<void> uploadAvatar(String filePath) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.agentMeAvatar}');

    final String fileName = filePath.split(RegExp(r'[\\/]')).last;
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.agentMeAvatar,
      data: formData,
    );

    _requireSuccess(response.data, response.statusCode);
  }

  @override
  Future<CompleteProfileModel> completeProfile({
    required String fullName,
    required String phone,
    required String jobTitle,
    required String bio,
    String instagram = '',
    String website = '',
    List<String> specialties = const <String>[],
  }) async {
    AppLog.line('[DATA SOURCE] PUT ${ApiEndpoints.agentMe}');

    final Map<String, dynamic> body = <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
      'jobTitle': jobTitle,
      'bio': bio,
      'instagram': instagram,
      'website': website,
      'specialties': specialties,
    };

    final response = await _apiClient.put<dynamic>(
      ApiEndpoints.agentMe,
      data: body,
    );

    final envelope = _requireSuccess(response.data, response.statusCode);
    return CompleteProfileModel.fromEnvelope(message: envelope.message);
  }

  ApiEnvelope _requireSuccess(dynamic raw, int? statusCode) {
    final ApiEnvelope envelope = ApiEnvelope.from(raw);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: statusCode,
      );
    }
    return envelope;
  }
}
