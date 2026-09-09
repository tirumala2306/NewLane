import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/repositories/marketing_request_repository.dart';

class GetMarketingRequests
    implements
        UseCase<Result<List<MarketingRequest>>, GetMarketingRequestsParams> {
  const GetMarketingRequests(this._repository);

  final MarketingRequestRepository _repository;

  @override
  Future<Result<List<MarketingRequest>>> call(
    GetMarketingRequestsParams params,
  ) {
    return _repository.getRequests(
      status: params.status,
      search: params.search,
    );
  }
}

class GetMarketingRequestsParams extends Equatable {
  const GetMarketingRequestsParams({
    this.status = 'active',
    this.search = '',
  });

  final String status;
  final String search;

  @override
  List<Object?> get props => <Object?>[status, search];
}
