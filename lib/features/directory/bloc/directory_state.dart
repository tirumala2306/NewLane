import 'package:equatable/equatable.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

sealed class DirectoryState extends Equatable {
  const DirectoryState();

  @override
  List<Object?> get props => <Object?>[];
}

class DirectoryInitial extends DirectoryState {
  const DirectoryInitial();
}

class DirectoryLoading extends DirectoryState {
  const DirectoryLoading({this.previous});

  final DirectoryAgentsPage? previous;

  @override
  List<Object?> get props => <Object?>[previous];
}

class DirectoryLoaded extends DirectoryState {
  const DirectoryLoaded(this.page);

  final DirectoryAgentsPage page;

  @override
  List<Object?> get props => <Object?>[page];
}

class DirectoryFailure extends DirectoryState {
  const DirectoryFailure(this.message, {this.previous});

  final String message;
  final DirectoryAgentsPage? previous;

  @override
  List<Object?> get props => <Object?>[message, previous];
}
