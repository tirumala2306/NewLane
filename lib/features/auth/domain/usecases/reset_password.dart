import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/reset_password_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class ResetPassword
    implements UseCase<Result<ResetPasswordResult>, ResetPasswordParams> {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<ResetPasswordResult>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      resetToken: params.resetToken,
      password: params.password,
    );
  }
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.resetToken,
    required this.password,
    required this.confirmPassword,
  });

  final String resetToken;
  final String password;
  final String confirmPassword;

  @override
  List<Object> get props => <Object>[resetToken, password, confirmPassword];
}
