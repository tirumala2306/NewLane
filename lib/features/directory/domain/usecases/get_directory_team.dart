import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/repositories/directory_repository.dart';

class GetDirectoryTeam
    implements UseCase<Result<DirectoryAgentsPage>, GetDirectoryTeamParams> {
  const GetDirectoryTeam(this._repository);

  final DirectoryRepository _repository;

  @override
  Future<Result<DirectoryAgentsPage>> call(GetDirectoryTeamParams params) {
    return _repository.getTeam(
      search: params.search,
      department: params.department,
    );
  }
}

class GetDirectoryTeamParams extends Equatable {
  const GetDirectoryTeamParams({
    this.search = '',
    this.department = 'All',
  });

  final String search;
  final String department;

  @override
  List<Object?> get props => <Object?>[search, department];
}
