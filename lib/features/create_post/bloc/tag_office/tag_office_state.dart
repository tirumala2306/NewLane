import 'package:equatable/equatable.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';

sealed class TagOfficeState extends Equatable {
  const TagOfficeState();

  @override
  List<Object?> get props => <Object?>[];
}

class TagOfficeInitial extends TagOfficeState {
  const TagOfficeInitial();
}

class TagOfficeLoading extends TagOfficeState {
  const TagOfficeLoading({this.previousOffices, this.selectedOfficeId});

  final List<Office>? previousOffices;
  final int? selectedOfficeId;

  @override
  List<Object?> get props => <Object?>[previousOffices, selectedOfficeId];
}

class TagOfficeLoaded extends TagOfficeState {
  const TagOfficeLoaded({
    required this.offices,
    this.query = '',
    this.selectedOfficeId,
  });

  final List<Office> offices;
  final String query;
  final int? selectedOfficeId;

  @override
  List<Object?> get props => <Object?>[offices, query, selectedOfficeId];
}

class TagOfficeFailure extends TagOfficeState {
  const TagOfficeFailure({
    required this.message,
    this.previousOffices,
    this.selectedOfficeId,
  });

  final String message;
  final List<Office>? previousOffices;
  final int? selectedOfficeId;

  @override
  List<Object?> get props =>
      <Object?>[message, previousOffices, selectedOfficeId];
}
