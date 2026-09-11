import 'package:equatable/equatable.dart';

sealed class TagPeopleEvent extends Equatable {
  const TagPeopleEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

class TagPeopleStarted extends TagPeopleEvent {
  const TagPeopleStarted({this.selectedIds = const <int>[]});

  final List<int> selectedIds;

  @override
  List<Object?> get props => <Object?>[selectedIds];
}

class TagPeopleSearchChanged extends TagPeopleEvent {
  const TagPeopleSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class TagPeopleToggled extends TagPeopleEvent {
  const TagPeopleToggled(this.agentId);

  final int agentId;

  @override
  List<Object?> get props => <Object?>[agentId];
}
