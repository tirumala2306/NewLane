import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/auth/domain/entities/access_request_result.dart';
import 'package:newlane/features/auth/domain/entities/access_request_status.dart';
import 'package:newlane/features/auth/domain/entities/activate_account_result.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/domain/entities/complete_profile_result.dart';
import 'package:newlane/features/auth/domain/entities/forgot_password_result.dart';
import 'package:newlane/features/auth/domain/entities/login_result.dart';
import 'package:newlane/features/auth/domain/entities/reset_password_result.dart';

abstract class AuthRepository {
  Future<Result<AccessRequestResult>> submitAccessRequest({
    required String fullName,
    required String workEmail,
    required String brokerageName,
    required String phone,
  });

  Future<Result<AccessRequestStatus>> getAccessRequestStatus();

  Future<Result<ActivateAccountResult>> activateAccount({
    required String activationToken,
    required String password,
    required String confirmPassword,
  });

  Future<Result<LoginResult>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Result<ForgotPasswordResult>> forgotPassword({required String email});

  Future<Result<ResetPasswordResult>> resetPassword({
    required String resetToken,
    required String password,
  });

  Future<void> logout();

  Future<Result<AgentProfile>> getAgentMe();

  Future<Result<CompleteProfileResult>> completeProfile({
    required String fullName,
    required String phone,
    required String jobTitle,
    required String bio,
    String instagram = '',
    String website = '',
    List<String> specialties = const <String>[],
    String? avatarFilePath,
  });
}
