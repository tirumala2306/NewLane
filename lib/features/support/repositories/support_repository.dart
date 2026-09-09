import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';

abstract class SupportRepository {
  Future<Result<List<SupportTicket>>> getMyTickets({int? currentUserId});

  Future<Result<SupportTicket>> getTicketById(
    int ticketId, {
    int? currentUserId,
  });

  Future<Result<SupportTicket>> createTicket({
    required String category,
    required String subject,
    required String description,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  });

  Future<Result<SupportTicket>> replyToTicket({
    required int ticketId,
    required String message,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  });
}
