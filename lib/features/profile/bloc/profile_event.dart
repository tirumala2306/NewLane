import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads profile once. Pass [force] after edit / approval to refetch.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({this.force = false});

  final bool force;

  @override
  List<Object?> get props => <Object?>[force];
}
