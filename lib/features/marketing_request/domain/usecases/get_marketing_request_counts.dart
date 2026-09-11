import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/core/utils/app_log.dart';
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
    final List<Result<List<MarketingRequest>>> results =
        await Future.wait(<Future<Result<List<MarketingRequest>>>>[
          _getMarketingRequests(
            const GetMarketingRequestsParams(status: 'active'),
          ),
          _getMarketingRequests(
            const GetMarketingRequestsParams(status: 'completed'),
          ),
        ]);

    Failure? failure;
    final Map<int, MarketingRequest> byId = <int, MarketingRequest>{};
    final Set<int> completedIds = <int>{};

    results[0].when(
      ok: (List<MarketingRequest> list) {
        for (int i = 0; i < list.length; i++) {
          final MarketingRequest r = list[i];
          final int key = r.id > 0 ? r.id : -1000 - i;
          byId[key] = r;
        }
      },
      err: (Failure f) => failure = f,
    );

    results[1].when(
      ok: (List<MarketingRequest> list) {
        for (int i = 0; i < list.length; i++) {
          final MarketingRequest r = list[i];
          final int key = r.id > 0 ? r.id : -2000 - i;
          completedIds.add(key);
          // Completed endpoint wins — treat as completed even if status field is odd.
          byId[key] = MarketingRequest(
            id: r.id,
            requestType: r.requestType,
            listingAddress: r.listingAddress,
            listingPrice: r.listingPrice,
            notes: r.notes,
            status: MarketingRequestStatus.completed,
            listingTitle: r.listingTitle,
            thumbnailUrl: r.thumbnailUrl,
            createdAt: r.createdAt,
            mediaUrls: r.mediaUrls,
            finalFiles: r.finalFiles,
          );
        }
      },
      err: (Failure f) => failure ??= f,
    );

    if (byId.isEmpty && failure != null) {
      return Err<MarketingRequestCounts>(failure!);
    }

    int inProgress = 0;
    int pendingReview = 0;
    int completed = 0;

    for (final MarketingRequest request in byId.values) {
      if (completedIds.contains(request.id) ||
          request.status == MarketingRequestStatus.completed) {
        completed++;
        continue;
      }
      switch (request.status) {
        case MarketingRequestStatus.inProgress:
          inProgress++;
        case MarketingRequestStatus.submitted:
          pendingReview++;
        case MarketingRequestStatus.completed:
          completed++;
      }
    }

    AppLog.line(
      '[COUNTS] inProgress=$inProgress completed=$completed '
      'pendingReview=$pendingReview total=${byId.length}',
    );

    return Ok<MarketingRequestCounts>(
      MarketingRequestCounts(
        inProgress: inProgress,
        completed: completed,
        pendingReview: pendingReview,
      ),
    );
  }
}
