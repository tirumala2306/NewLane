import 'package:equatable/equatable.dart';

sealed class TagOfficeEvent extends Equatable {
  const TagOfficeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class TagOfficeStarted extends TagOfficeEvent {
  const TagOfficeStarted({this.selectedOfficeId});

  final int? selectedOfficeId;

  @override
  List<Object?> get props => <Object?>[selectedOfficeId];
}

class TagOfficeSearchChanged extends TagOfficeEvent {
  const TagOfficeSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class TagOfficeSelected extends TagOfficeEvent {
  const TagOfficeSelected(this.officeId);

  final int officeId;

  @override
  List<Object?> get props => <Object?>[officeId];
}
