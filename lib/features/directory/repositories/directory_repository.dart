import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

abstract class DirectoryRepository {
  Future<Result<DirectoryAgentsPage>> getAgents({
    String search = '',
    String office = '',
    String specialty = '',
    String sort = 'name_asc',
  });

  Future<Result<DirectoryAgentsPage>> getTeam({
    String search = '',
    String department = 'All',
  });
}
