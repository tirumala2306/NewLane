import 'package:equatable/equatable.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/domain/entities/complete_profile_result.dart';

sealed class CompleteProfileState extends Equatable {
  const CompleteProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class CompleteProfileInitial extends CompleteProfileState {
  const CompleteProfileInitial();
}

class CompleteProfileLoading extends CompleteProfileState {
  const CompleteProfileLoading();
}

class CompleteProfileReady extends CompleteProfileState {
  const CompleteProfileReady({this.profile});

  final AgentProfile? profile;

  @override
  List<Object?> get props => <Object?>[profile];
}

class CompleteProfileSuccess extends CompleteProfileState {
  const CompleteProfileSuccess(this.result);

  final CompleteProfileResult result;

  @override
  List<Object?> get props => <Object?>[result];
}

class CompleteProfileFailure extends CompleteProfileState {
  const CompleteProfileFailure({
    required this.message,
    this.isValidation = false,
  });

  final String message;
  final bool isValidation;

  @override
  List<Object?> get props => <Object?>[message, isValidation];
}
