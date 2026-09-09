import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/access_request_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class SubmitAccessRequest
    implements UseCase<Result<AccessRequestResult>, SubmitAccessRequestParams> {
  const SubmitAccessRequest(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AccessRequestResult>> call(SubmitAccessRequestParams params) {
    return _repository.submitAccessRequest(
      fullName: params.fullName,
      workEmail: params.workEmail,
      brokerageName: params.brokerageName,
      phone: params.phone,
    );
  }
}

class SubmitAccessRequestParams extends Equatable {
  const SubmitAccessRequestParams({
    required this.fullName,
    required this.workEmail,
    required this.brokerageName,
    required this.phone,
  });

  final String fullName;
  final String workEmail;
  final String brokerageName;
  final String phone;

  @override
  List<Object> get props =>
      <Object>[fullName, workEmail, brokerageName, phone];
}
