import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/domain/usecases/get_training_resources.dart';

part 'training_event.dart';
part 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  TrainingBloc({required GetTrainingResources getTrainingResources})
      : _getTrainingResources = getTrainingResources,
        super(const TrainingInitial()) {
    on<TrainingStarted>(_onStarted);
    on<TrainingRefreshed>(_onRefreshed);
  }

  final GetTrainingResources _getTrainingResources;

  Future<void> _onStarted(
    TrainingStarted event,
    Emitter<TrainingState> emit,
  ) async {
    emit(const TrainingLoading());
    await _load(emit);
  }

  Future<void> _onRefreshed(
    TrainingRefreshed event,
    Emitter<TrainingState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<TrainingState> emit) async {
    final Result<List<TrainingResource>> result =
        await _getTrainingResources(const GetTrainingResourcesParams());
    result.when(
      ok: (List<TrainingResource> resources) {
        AppLog.line('[TRAINING] loaded ${resources.length}');
        emit(TrainingLoaded(resources: resources));
      },
      err: (failure) {
        AppLog.line('[TRAINING] error ${failure.message}');
        emit(TrainingError(failure.message));
      },
    );
  }
}
