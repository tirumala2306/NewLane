import 'package:equatable/equatable.dart';

sealed class MyRequestsEvent extends Equatable {
  const MyRequestsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class MyRequestsStarted extends MyRequestsEvent {
  const MyRequestsStarted();
}

class MyRequestsTabChanged extends MyRequestsEvent {
  const MyRequestsTabChanged({required this.completed});
  final bool completed;

  @override
  List<Object?> get props => <Object?>[completed];
}

class MyRequestsSearchChanged extends MyRequestsEvent {
  const MyRequestsSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class MyRequestsRefreshed extends MyRequestsEvent {
  const MyRequestsRefreshed();
}
