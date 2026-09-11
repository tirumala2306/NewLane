import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/listings/domain/entities/active_listing.dart';

abstract class ListingsRepository {
  Future<Result<List<ActiveListing>>> getMyActiveListings({
    required int currentUserId,
    required String currentUserName,
  });

  Future<Result<List<ActiveListing>>> getActiveListingsForAgent({
    required int agentId,
    required String agentName,
  });
}
