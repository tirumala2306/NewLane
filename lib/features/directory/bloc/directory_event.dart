import 'package:equatable/equatable.dart';

sealed class DirectoryEvent extends Equatable {
  const DirectoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class DirectoryStarted extends DirectoryEvent {
  const DirectoryStarted();
}

class DirectorySearchChanged extends DirectoryEvent {
  const DirectorySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class DirectoryRefreshed extends DirectoryEvent {
  const DirectoryRefreshed();
}
