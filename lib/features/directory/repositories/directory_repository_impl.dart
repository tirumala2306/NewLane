import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/directory/data/datasources/directory_remote_data_source.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/repositories/directory_repository.dart';

class DirectoryRepositoryImpl implements DirectoryRepository {
  const DirectoryRepositoryImpl({required DirectoryRemoteDataSource remote})
    : _remote = remote;

  final DirectoryRemoteDataSource _remote;

  @override
  Future<Result<DirectoryAgentsPage>> getAgents({
    String search = '',
    String office = '',
    String specialty = '',
    String sort = 'name_asc',
  }) {
    return _guard(() async {
      final model = await _remote.getAgents(
        search: search,
        office: office,
        specialty: specialty,
        sort: sort,
      );
      AppLog.line(
        '[REPO] directory agents OK total=${model.total} page=${model.page}',
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<DirectoryAgentsPage>> getTeam({
    String search = '',
    String department = 'All',
  }) {
    return _guard(() async {
      final model = await _remote.getTeam(
        search: search,
        department: department,
      );
      AppLog.line(
        '[REPO] directory team OK total=${model.total} page=${model.page}',
      );
      return model.toEntity();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok<T>(await action());
    } on ValidationException catch (error) {
      return Err<T>(ValidationFailure(error.message));
    } on NetworkException catch (error) {
      return Err<T>(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Err<T>(ServerFailure(error.message, statusCode: error.statusCode));
    } catch (error) {
      AppLog.line('[REPO] directory UNKNOWN error: $error');
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
