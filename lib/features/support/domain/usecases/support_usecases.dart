import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/repositories/support_repository.dart';

class GetMySupportTickets
    implements UseCase<Result<List<SupportTicket>>, GetMySupportTicketsParams> {
  const GetMySupportTickets(this._repository);

  final SupportRepository _repository;

  @override
  Future<Result<List<SupportTicket>>> call(GetMySupportTicketsParams params) {
    return _repository.getMyTickets(currentUserId: params.currentUserId);
  }
}

class GetMySupportTicketsParams extends Equatable {
  const GetMySupportTicketsParams({this.currentUserId});

  final int? currentUserId;

  @override
  List<Object?> get props => <Object?>[currentUserId];
}

class GetSupportTicketById
    implements UseCase<Result<SupportTicket>, GetSupportTicketByIdParams> {
  const GetSupportTicketById(this._repository);

  final SupportRepository _repository;

  @override
  Future<Result<SupportTicket>> call(GetSupportTicketByIdParams params) {
    return _repository.getTicketById(
      params.ticketId,
      currentUserId: params.currentUserId,
    );
  }
}

class GetSupportTicketByIdParams extends Equatable {
  const GetSupportTicketByIdParams({
    required this.ticketId,
    this.currentUserId,
  });

  final int ticketId;
  final int? currentUserId;

  @override
  List<Object?> get props => <Object?>[ticketId, currentUserId];
}

class CreateSupportTicket
    implements UseCase<Result<SupportTicket>, CreateSupportTicketParams> {
  const CreateSupportTicket(this._repository);

  final SupportRepository _repository;

  @override
  Future<Result<SupportTicket>> call(CreateSupportTicketParams params) {
    return _repository.createTicket(
      category: params.category,
      subject: params.subject,
      description: params.description,
      attachmentPaths: params.attachmentPaths,
      currentUserId: params.currentUserId,
    );
  }
}

class CreateSupportTicketParams extends Equatable {
  const CreateSupportTicketParams({
    required this.category,
    required this.subject,
    required this.description,
    this.attachmentPaths = const <String>[],
    this.currentUserId,
  });

  final String category;
  final String subject;
  final String description;
  final List<String> attachmentPaths;
  final int? currentUserId;

  @override
  List<Object?> get props => <Object?>[
        category,
        subject,
        description,
        attachmentPaths,
        currentUserId,
      ];
}

class ReplySupportTicket
    implements UseCase<Result<SupportTicket>, ReplySupportTicketParams> {
  const ReplySupportTicket(this._repository);

  final SupportRepository _repository;

  @override
  Future<Result<SupportTicket>> call(ReplySupportTicketParams params) {
    return _repository.replyToTicket(
      ticketId: params.ticketId,
      message: params.message,
      attachmentPaths: params.attachmentPaths,
      currentUserId: params.currentUserId,
    );
  }
}

class ReplySupportTicketParams extends Equatable {
  const ReplySupportTicketParams({
    required this.ticketId,
    required this.message,
    this.attachmentPaths = const <String>[],
    this.currentUserId,
  });

  final int ticketId;
  final String message;
  final List<String> attachmentPaths;
  final int? currentUserId;

  @override
  List<Object?> get props =>
      <Object?>[ticketId, message, attachmentPaths, currentUserId];
}
