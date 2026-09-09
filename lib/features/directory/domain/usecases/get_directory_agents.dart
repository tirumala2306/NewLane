import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/repositories/directory_repository.dart';

class GetDirectoryAgents
    implements UseCase<Result<DirectoryAgentsPage>, GetDirectoryAgentsParams> {
  const GetDirectoryAgents(this._repository);

  final DirectoryRepository _repository;

  @override
  Future<Result<DirectoryAgentsPage>> call(GetDirectoryAgentsParams params) {
    return _repository.getAgents(
      search: params.search,
      office: params.office,
      specialty: params.specialty,
      sort: params.sort,
    );
  }
}

class GetDirectoryAgentsParams extends Equatable {
  const GetDirectoryAgentsParams({
    this.search = '',
    this.office = '',
    this.specialty = '',
    this.sort = 'name_asc',
  });

  final String search;
  final String office;
  final String specialty;
  final String sort;

  @override
  List<Object?> get props => <Object?>[search, office, specialty, sort];
}
