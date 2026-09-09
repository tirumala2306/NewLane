import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/forgot_password_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class ForgotPassword
    implements UseCase<Result<ForgotPasswordResult>, ForgotPasswordParams> {
  const ForgotPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<ForgotPasswordResult>> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams extends Equatable {
  const ForgotPasswordParams({required this.email});

  final String email;

  @override
  List<Object> get props => <Object>[email];
}
