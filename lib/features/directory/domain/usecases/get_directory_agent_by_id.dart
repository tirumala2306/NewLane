import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/repositories/directory_repository.dart';

class GetDirectoryAgentById
    implements UseCase<Result<DirectoryAgent>, GetDirectoryAgentByIdParams> {
  const GetDirectoryAgentById(this._repository);

  final DirectoryRepository _repository;

  @override
  Future<Result<DirectoryAgent>> call(GetDirectoryAgentByIdParams params) {
    return _repository.getAgentById(params.agentId);
  }
}

class GetDirectoryAgentByIdParams extends Equatable {
  const GetDirectoryAgentByIdParams(this.agentId);

  final int agentId;

  @override
  List<Object?> get props => <Object?>[agentId];
}
