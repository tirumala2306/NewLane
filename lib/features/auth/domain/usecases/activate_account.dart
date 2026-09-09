import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/activate_account_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class ActivateAccount
    implements UseCase<Result<ActivateAccountResult>, ActivateAccountParams> {
  const ActivateAccount(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<ActivateAccountResult>> call(ActivateAccountParams params) {
    return _repository.activateAccount(
      activationToken: params.activationToken,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

class ActivateAccountParams {
  const ActivateAccountParams({
    required this.activationToken,
    required this.password,
    required this.confirmPassword,
  });

  final String activationToken;
  final String password;
  final String confirmPassword;
}
