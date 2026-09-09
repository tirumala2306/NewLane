import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

abstract class MarketingRequestRepository {
  Future<Result<MarketingRequestSubmitResult>> createRequest({
    required String requestType,
    required String listingAddress,
    required String listingPrice,
    required String notes,
    List<String> mediaPaths = const <String>[],
  });

  Future<Result<List<MarketingRequest>>> getRequests({
    String status = 'active',
    String search = '',
  });

  Future<Result<MarketingRequest>> getRequestById(int id);
}
