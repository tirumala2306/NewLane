import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/support/data/datasources/support_remote_data_source.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl({required SupportRemoteDataSource remote})
    : _remote = remote;

  final SupportRemoteDataSource _remote;

  @override
  Future<Result<List<SupportTicket>>> getMyTickets({int? currentUserId}) {
    return _guard(() async {
      final model = await _remote.getMyTickets(currentUserId: currentUserId);
      return model.toEntities();
    });
  }

  @override
  Future<Result<SupportTicket>> getTicketById(
    int ticketId, {
    int? currentUserId,
  }) {
    return _guard(() async {
      final model = await _remote.getTicketById(
        ticketId,
        currentUserId: currentUserId,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<SupportTicket>> createTicket({
    required String category,
    required String subject,
    required String description,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  }) {
    return _guard(() async {
      final model = await _remote.createTicket(
        category: category,
        subject: subject,
        description: description,
        attachmentPaths: attachmentPaths,
        currentUserId: currentUserId,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<SupportTicket>> replyToTicket({
    required int ticketId,
    required String message,
    List<String> attachmentPaths = const <String>[],
    int? currentUserId,
  }) {
    return _guard(() async {
      final model = await _remote.replyToTicket(
        ticketId: ticketId,
        message: message,
        attachmentPaths: attachmentPaths,
        currentUserId: currentUserId,
      );
      return model.toEntity();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok<T>(await action());
    } on ValidationException catch (error) {
      return Err<T>(ValidationFailure(error.message));
    } on NetworkException catch (error) {
      return Err<T>(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Err<T>(ServerFailure(error.message, statusCode: error.statusCode));
    } catch (error) {
      AppLog.line('[REPO] support UNKNOWN error: $error');
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
