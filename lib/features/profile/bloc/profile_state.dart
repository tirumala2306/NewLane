import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final AgentProfile profile;

  @override
  List<Object?> get props => <Object?>[profile];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
