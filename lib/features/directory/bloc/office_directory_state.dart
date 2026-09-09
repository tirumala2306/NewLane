import 'package:equatable/equatable.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

sealed class OfficeDirectoryState extends Equatable {
  const OfficeDirectoryState({
    this.department = 'All',
    this.officeName = '',
  });

  final String department;
  final String officeName;

  @override
  List<Object?> get props => <Object?>[department, officeName];
}

class OfficeDirectoryInitial extends OfficeDirectoryState {
  const OfficeDirectoryInitial();
}

class OfficeDirectoryLoading extends OfficeDirectoryState {
  const OfficeDirectoryLoading({
    this.previous,
    super.department,
    super.officeName,
  });

  final DirectoryAgentsPage? previous;

  @override
  List<Object?> get props => <Object?>[previous, department, officeName];
}

class OfficeDirectoryLoaded extends OfficeDirectoryState {
  const OfficeDirectoryLoaded({
    required this.page,
    super.department,
    super.officeName,
  });

  final DirectoryAgentsPage page;

  @override
  List<Object?> get props => <Object?>[page, department, officeName];
}

class OfficeDirectoryFailure extends OfficeDirectoryState {
  const OfficeDirectoryFailure(
    this.message, {
    this.previous,
    super.department,
    super.officeName,
  });

  final String message;
  final DirectoryAgentsPage? previous;

  @override
  List<Object?> get props => <Object?>[message, previous, department, officeName];
}
