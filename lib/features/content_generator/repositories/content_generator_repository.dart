import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';

abstract class ContentGeneratorRepository {
  Future<Result<ContentGenerateResult>> generate(ContentGeneratorDraft draft);

  Future<Result<List<ContentTemplate>>> getTemplates();
}
