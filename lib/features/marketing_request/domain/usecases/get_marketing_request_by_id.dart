import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/repositories/marketing_request_repository.dart';

class GetMarketingRequestById
    implements UseCase<Result<MarketingRequest>, GetMarketingRequestByIdParams> {
  const GetMarketingRequestById(this._repository);

  final MarketingRequestRepository _repository;

  @override
  Future<Result<MarketingRequest>> call(GetMarketingRequestByIdParams params) {
    return _repository.getRequestById(params.id);
  }
}

class GetMarketingRequestByIdParams extends Equatable {
  const GetMarketingRequestByIdParams(this.id);

  final int id;

  @override
  List<Object?> get props => <Object?>[id];
}
