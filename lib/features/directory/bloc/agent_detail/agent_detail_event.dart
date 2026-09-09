import 'package:equatable/equatable.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

abstract class AgentDetailEvent extends Equatable {
  const AgentDetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AgentDetailStarted extends AgentDetailEvent {
  const AgentDetailStarted({
    required this.agentId,
    this.initial,
  });

  final int agentId;
  final DirectoryAgent? initial;

  @override
  List<Object?> get props => <Object?>[agentId, initial];
}

class AgentDetailMessagePressed extends AgentDetailEvent {
  const AgentDetailMessagePressed();
}
