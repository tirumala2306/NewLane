import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/login_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class Login implements UseCase<Result<LoginResult>, LoginParams> {
  const Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<LoginResult>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final bool rememberMe;

  @override
  List<Object> get props => <Object>[email, password, rememberMe];
}
