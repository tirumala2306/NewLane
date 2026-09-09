import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/storage/app_storage.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:newlane/features/auth/domain/entities/access_request_result.dart';
import 'package:newlane/features/auth/domain/entities/access_request_status.dart';
import 'package:newlane/features/auth/domain/entities/activate_account_result.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/domain/entities/complete_profile_result.dart';
import 'package:newlane/features/auth/domain/entities/forgot_password_result.dart';
import 'package:newlane/features/auth/domain/entities/login_result.dart';
import 'package:newlane/features/auth/domain/entities/reset_password_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AppStorage storage,
  }) : _remoteDataSource = remoteDataSource,
       _storage = storage;

  final AuthRemoteDataSource _remoteDataSource;
  final AppStorage _storage;

  @override
  Future<Result<AccessRequestResult>> submitAccessRequest({
    required String fullName,
    required String workEmail,
    required String brokerageName,
    required String phone,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.submitAccessRequest(
        fullName: fullName,
        workEmail: workEmail,
        brokerageName: brokerageName,
        phone: phone,
      );

      if (model.requestId > 0) {
        await _storage.saveInt(AppConstants.accessRequestIdKey, model.requestId);
        await _storage.saveString(
          AppConstants.accessRequestFullNameKey,
          fullName,
        );
        await _storage.saveString(
          AppConstants.accessRequestWorkEmailKey,
          workEmail,
        );
        await _storage.saveString(
          AppConstants.accessRequestBrokerageKey,
          brokerageName,
        );
        await _storage.saveString(AppConstants.accessRequestPhoneKey, phone);
        await _storage.setOnboardingCompleted();
        AppLog.line('[REPO] saved accessRequestId=${model.requestId}');
      }

      AppLog.line(
        '[REPO] access request OK id=${model.requestId} msg=${model.message}',
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<AccessRequestStatus>> getAccessRequestStatus() {
    return _guard(() async {
      final int? requestId = _storage.readInt(AppConstants.accessRequestIdKey);
      if (requestId == null || requestId <= 0) {
        throw const ValidationException(
          'No access request found. Please submit a request first.',
        );
      }

      AppLog.line('[REPO] GET status for accessRequestId=$requestId');
      final model = await _remoteDataSource.getAccessRequestStatus(requestId);
      AppLog.line('[REPO] status OK → $model');
      return model.toEntity();
    });
  }

  @override
  Future<Result<ActivateAccountResult>> activateAccount({
    required String activationToken,
    required String password,
    required String confirmPassword,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.activateAccount(
        activationToken: activationToken,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (model.token.isNotEmpty) {
        await _storage.saveString(AppConstants.authTokenKey, model.token);
        await _storage.setOnboardingCompleted();
        AppLog.line('[REPO] saved auth token after activation');
      }

      AppLog.line('[REPO] activate OK → ${model.message}');
      return model.toEntity();
    });
  }

  @override
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      if (model.token.isEmpty) {
        throw const ServerException(
          'No auth token returned. Please try again.',
        );
      }

      await _storage.saveString(AppConstants.authTokenKey, model.token);
      await _storage.setOnboardingCompleted();
      AppLog.line('[REPO] saved auth token after login');

      await _storage.saveRememberMe(enabled: rememberMe, email: email);

      AppLog.line('[REPO] login OK → ${model.message} status=${model.status}');
      return model.toEntity();
    });
  }

  @override
  Future<Result<ForgotPasswordResult>> forgotPassword({
    required String email,
  }) {
    return _guard(() async {
      final String message = await _remoteDataSource.forgotPassword(
        email: email,
      );
      AppLog.line('[REPO] forgot password OK → $message');
      return ForgotPasswordResult(message: message);
    });
  }

  @override
  Future<Result<ResetPasswordResult>> resetPassword({
    required String resetToken,
    required String password,
  }) {
    return _guard(() async {
      final String message = await _remoteDataSource.resetPassword(
        resetToken: resetToken,
        password: password,
      );
      AppLog.line('[REPO] reset password OK → $message');
      return ResetPasswordResult(message: message);
    });
  }

  @override
  Future<void> logout() async {
    await _storage.clearAuthSession();
    AppLog.line('[REPO] logged out — auth token cleared');
  }

  @override
  Future<Result<AgentProfile>> getAgentMe() {
    return _guard(() async {
      final model = await _remoteDataSource.getAgentMe();
      AppLog.line('[REPO] get agent me OK id=${model.id}');
      return model.toEntity();
    });
  }

  @override
  Future<Result<CompleteProfileResult>> completeProfile({
    required String fullName,
    required String phone,
    required String jobTitle,
    required String bio,
    String instagram = '',
    String website = '',
    List<String> specialties = const <String>[],
    String? avatarFilePath,
  }) {
    return _guard(() async {
      if (avatarFilePath != null && avatarFilePath.trim().isNotEmpty) {
        await _remoteDataSource.uploadAvatar(avatarFilePath.trim());
        AppLog.line('[REPO] avatar uploaded');
      }

      final model = await _remoteDataSource.completeProfile(
        fullName: fullName,
        phone: phone,
        jobTitle: jobTitle,
        bio: bio,
        instagram: instagram,
        website: website,
        specialties: specialties,
      );
      AppLog.line('[REPO] complete profile OK → ${model.message}');
      return model.toEntity();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok<T>(await action());
    } on ValidationException catch (error) {
      AppLog.line('[REPO] VALIDATION error: ${error.message}');
      return Err<T>(ValidationFailure(error.message));
    } on NetworkException catch (error) {
      AppLog.line('[REPO] NETWORK error: ${error.message}');
      return Err<T>(NetworkFailure(error.message));
    } on ServerException catch (error) {
      AppLog.line('[REPO] SERVER error (${error.statusCode}): ${error.message}');
      return Err<T>(ServerFailure(error.message, statusCode: error.statusCode));
    } catch (error) {
      AppLog.line('[REPO] UNKNOWN error: $error');
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
