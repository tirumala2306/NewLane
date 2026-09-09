import 'package:equatable/equatable.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

sealed class AgentDetailState extends Equatable {
  const AgentDetailState();

  @override
  List<Object?> get props => <Object?>[];
}

class AgentDetailInitial extends AgentDetailState {
  const AgentDetailInitial();
}

class AgentDetailLoading extends AgentDetailState {
  const AgentDetailLoading({this.agent});

  final DirectoryAgent? agent;

  @override
  List<Object?> get props => <Object?>[agent];
}

class AgentDetailLoaded extends AgentDetailState {
  const AgentDetailLoaded(this.agent, {this.isStartingChat = false});

  final DirectoryAgent agent;
  final bool isStartingChat;

  @override
  List<Object?> get props => <Object?>[agent, isStartingChat];
}

class AgentDetailFailure extends AgentDetailState {
  const AgentDetailFailure(this.message, {this.agent});

  final String message;
  final DirectoryAgent? agent;

  @override
  List<Object?> get props => <Object?>[message, agent];
}

class AgentDetailChatReady extends AgentDetailState {
  const AgentDetailChatReady({
    required this.agent,
    required this.chatId,
  });

  final DirectoryAgent agent;
  final String chatId;

  @override
  List<Object?> get props => <Object?>[agent, chatId];
}
