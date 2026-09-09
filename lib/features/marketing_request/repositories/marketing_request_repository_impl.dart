import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/marketing_request/data/datasources/marketing_request_remote_data_source.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/repositories/marketing_request_repository.dart';

class MarketingRequestRepositoryImpl implements MarketingRequestRepository {
  const MarketingRequestRepositoryImpl({
    required MarketingRequestRemoteDataSource remote,
  }) : _remote = remote;

  final MarketingRequestRemoteDataSource _remote;

  @override
  Future<Result<MarketingRequestSubmitResult>> createRequest({
    required String requestType,
    required String listingAddress,
    required String listingPrice,
    required String notes,
    List<String> mediaPaths = const <String>[],
  }) {
    return _guard(() async {
      final model = await _remote.createRequest(
        requestType: requestType,
        listingAddress: listingAddress,
        listingPrice: listingPrice,
        notes: notes,
        mediaPaths: mediaPaths,
      );
      AppLog.line('[REPO] marketing request created');
      return model.toEntity();
    });
  }

  @override
  Future<Result<List<MarketingRequest>>> getRequests({
    String status = 'active',
    String search = '',
  }) {
    return _guard(() async {
      final model = await _remote.getRequests(
        status: status,
        search: search,
      );
      AppLog.line('[REPO] marketing requests ${model.requests.length}');
      return model.toEntities();
    });
  }

  @override
  Future<Result<MarketingRequest>> getRequestById(int id) {
    return _guard(() async {
      final model = await _remote.getRequestById(id);
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
      AppLog.line('[REPO] marketing request UNKNOWN error: $error');
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
