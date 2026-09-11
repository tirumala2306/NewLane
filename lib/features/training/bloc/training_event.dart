part of 'training_bloc.dart';

sealed class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class TrainingStarted extends TrainingEvent {
  const TrainingStarted();
}

class TrainingRefreshed extends TrainingEvent {
  const TrainingRefreshed();
}
