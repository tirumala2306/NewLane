import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/content_generator/data/datasources/content_generator_remote_data_source.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/repositories/content_generator_repository.dart';

class ContentGeneratorRepositoryImpl implements ContentGeneratorRepository {
  const ContentGeneratorRepositoryImpl({
    required ContentGeneratorRemoteDataSource remote,
  }) : _remote = remote;

  final ContentGeneratorRemoteDataSource _remote;

  @override
  Future<Result<ContentGenerateResult>> generate(ContentGeneratorDraft draft) {
    return _guard(() async {
      final model = await _remote.generate(draft);
      return model.toEntity();
    });
  }

  @override
  Future<Result<List<ContentTemplate>>> getTemplates() {
    return _guard(() async {
      final model = await _remote.getTemplates();
      return model.templates;
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
      AppLog.line('[REPO] content generator UNKNOWN error: $error');
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
