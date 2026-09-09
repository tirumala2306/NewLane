import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/access_request_status.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class GetAccessRequestStatus
    implements UseCase<Result<AccessRequestStatus>, NoParams> {
  const GetAccessRequestStatus(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AccessRequestStatus>> call(NoParams params) {
    return _repository.getAccessRequestStatus();
  }
}
