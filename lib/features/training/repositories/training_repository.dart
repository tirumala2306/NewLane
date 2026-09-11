import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';

abstract class TrainingRepository {
  Future<Result<List<TrainingResource>>> listResources({
    String? category,
    bool? featured,
  });

  Future<Result<TrainingResource>> getResource(int id);
}
