import 'package:equatable/equatable.dart';

sealed class OfficeDirectoryEvent extends Equatable {
  const OfficeDirectoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class OfficeDirectoryStarted extends OfficeDirectoryEvent {
  const OfficeDirectoryStarted();
}

class OfficeDirectorySearchChanged extends OfficeDirectoryEvent {
  const OfficeDirectorySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class OfficeDirectoryDepartmentChanged extends OfficeDirectoryEvent {
  const OfficeDirectoryDepartmentChanged(this.department);

  final String department;

  @override
  List<Object?> get props => <Object?>[department];
}

class OfficeDirectoryRefreshed extends OfficeDirectoryEvent {
  const OfficeDirectoryRefreshed();
}
