import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class GetAgentMe implements UseCase<Result<AgentProfile>, NoParams> {
  const GetAgentMe(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AgentProfile>> call(NoParams params) {
    return _repository.getAgentMe();
  }
}
