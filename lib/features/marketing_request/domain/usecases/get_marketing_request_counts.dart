import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/domain/usecases/get_marketing_requests.dart';

class MarketingRequestCounts {
  const MarketingRequestCounts({
    required this.inProgress,
    required this.completed,
    required this.pendingReview,
  });

  const MarketingRequestCounts.zero()
    : inProgress = 0,
      completed = 0,
      pendingReview = 0;

  final int inProgress;
  final int completed;
  final int pendingReview;
}

class GetMarketingRequestCounts
    implements UseCase<Result<MarketingRequestCounts>, NoParams> {
  const GetMarketingRequestCounts(this._getMarketingRequests);

  final GetMarketingRequests _getMarketingRequests;

  @override
  Future<Result<MarketingRequestCounts>> call(NoParams params) async {
    final Result<List<MarketingRequest>> activeResult =
        await _getMarketingRequests(
          const GetMarketingRequestsParams(status: 'active'),
        );
    final Result<List<MarketingRequest>> completedResult =
        await _getMarketingRequests(
          const GetMarketingRequestsParams(status: 'completed'),
        );

    Failure? failure;
    List<MarketingRequest> active = const <MarketingRequest>[];
    List<MarketingRequest> completed = const <MarketingRequest>[];

    activeResult.when(
      ok: (List<MarketingRequest> list) => active = list,
      err: (Failure f) => failure = f,
    );
    completedResult.when(
      ok: (List<MarketingRequest> list) => completed = list,
      err: (Failure f) => failure ??= f,
    );

    if (failure != null && active.isEmpty && completed.isEmpty) {
      return Err<MarketingRequestCounts>(failure!);
    }

    int inProgress = 0;
    int pendingReview = 0;
    for (final MarketingRequest request in active) {
      switch (request.status) {
        case MarketingRequestStatus.inProgress:
          inProgress++;
        case MarketingRequestStatus.submitted:
          pendingReview++;
        case MarketingRequestStatus.completed:
          break;
      }
    }

    return Ok<MarketingRequestCounts>(
      MarketingRequestCounts(
        inProgress: inProgress,
        completed: completed.length,
        pendingReview: pendingReview,
      ),
    );
  }
}
