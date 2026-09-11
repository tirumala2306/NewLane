import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/repositories/training_repository.dart';

class GetTrainingResources
    implements
        UseCase<Result<List<TrainingResource>>, GetTrainingResourcesParams> {
  const GetTrainingResources(this._repository);

  final TrainingRepository _repository;

  @override
  Future<Result<List<TrainingResource>>> call(
    GetTrainingResourcesParams params,
  ) {
    return _repository.listResources(
      category: params.category,
      featured: params.featured,
    );
  }
}

class GetTrainingResourcesParams {
  const GetTrainingResourcesParams({this.category, this.featured});

  final String? category;
  final bool? featured;
}
