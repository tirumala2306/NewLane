import 'package:equatable/equatable.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

sealed class TagPeopleState extends Equatable {
  const TagPeopleState();

  @override
  List<Object?> get props => const <Object?>[];
}

class TagPeopleInitial extends TagPeopleState {
  const TagPeopleInitial();
}

class TagPeopleLoading extends TagPeopleState {
  const TagPeopleLoading({
    this.previousAgents,
    this.selectedIds = const <int>{},
  });

  final List<DirectoryAgent>? previousAgents;
  final Set<int> selectedIds;

  @override
  List<Object?> get props => <Object?>[previousAgents, selectedIds];
}

class TagPeopleLoaded extends TagPeopleState {
  const TagPeopleLoaded({
    required this.agents,
    required this.query,
    required this.selectedIds,
  });

  final List<DirectoryAgent> agents;
  final String query;
  final Set<int> selectedIds;

  @override
  List<Object?> get props => <Object?>[agents, query, selectedIds];
}

class TagPeopleFailure extends TagPeopleState {
  const TagPeopleFailure({
    required this.message,
    this.previousAgents,
    this.selectedIds = const <int>{},
  });

  final String message;
  final List<DirectoryAgent>? previousAgents;
  final Set<int> selectedIds;

  @override
  List<Object?> get props => <Object?>[message, previousAgents, selectedIds];
}
