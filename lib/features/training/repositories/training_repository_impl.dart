import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/training/data/datasources/training_remote_data_source.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/repositories/training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  const TrainingRepositoryImpl({required TrainingRemoteDataSource remote})
      : _remote = remote;

  final TrainingRemoteDataSource _remote;

  @override
  Future<Result<List<TrainingResource>>> listResources({
    String? category,
    bool? featured,
  }) {
    return _guard(() async {
      final model = await _remote.listResources(
        category: category,
        featured: featured,
      );
      return model.toEntities();
    });
  }

  @override
  Future<Result<TrainingResource>> getResource(int id) {
    return _guard(() async {
      final model = await _remote.getResource(id);
      return model.toEntity();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ServerException catch (e) {
      AppLog.line('[TRAINING REPO] ${e.message}');
      return Err<T>(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLog.line('[TRAINING REPO] ${e.message}');
      return Err<T>(NetworkFailure(e.message));
    } catch (e) {
      AppLog.line('[TRAINING REPO] $e');
      return Err<T>(UnknownFailure(e.toString()));
    }
  }
}
