import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/create_post/data/datasources/offices_remote_data_source.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/create_post/repositories/offices_repository.dart';

class OfficesRepositoryImpl implements OfficesRepository {
  const OfficesRepositoryImpl({required OfficesRemoteDataSource remote})
    : _remote = remote;

  final OfficesRemoteDataSource _remote;

  @override
  Future<Result<List<Office>>> getOffices({String search = ''}) {
    return _guard(() async {
      final page = await _remote.getOffices(search: search);
      List<Office> offices = page.toEntities();

      // Client-side name filter if API returns full list / ignores search.
      final String q = search.trim().toLowerCase();
      if (q.isNotEmpty) {
        offices = offices
            .where(
              (Office o) =>
                  o.name.toLowerCase().contains(q) ||
                  o.city.toLowerCase().contains(q) ||
                  o.state.toLowerCase().contains(q),
            )
            .toList();
      }

      AppLog.line('[REPO] offices count=${offices.length}');
      return offices;
    });
  }

  @override
  Future<Result<Office>> getOfficeById(int officeId) {
    return _guard(() async {
      final model = await _remote.getOfficeById(officeId);
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
    } catch (_) {
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
