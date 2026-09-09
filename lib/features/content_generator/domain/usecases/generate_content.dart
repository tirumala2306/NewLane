import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/repositories/content_generator_repository.dart';

class GenerateContent
    implements UseCase<Result<ContentGenerateResult>, ContentGeneratorDraft> {
  const GenerateContent(this._repository);

  final ContentGeneratorRepository _repository;

  @override
  Future<Result<ContentGenerateResult>> call(ContentGeneratorDraft params) {
    return _repository.generate(params);
  }
}

class GetContentTemplates
    implements UseCase<Result<List<ContentTemplate>>, NoParams> {
  const GetContentTemplates(this._repository);

  final ContentGeneratorRepository _repository;

  @override
  Future<Result<List<ContentTemplate>>> call(NoParams params) {
    return _repository.getTemplates();
  }
}
