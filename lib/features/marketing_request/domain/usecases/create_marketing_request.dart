import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/repositories/marketing_request_repository.dart';

class CreateMarketingRequest
    implements
        UseCase<Result<MarketingRequestSubmitResult>, CreateMarketingRequestParams> {
  const CreateMarketingRequest(this._repository);

  final MarketingRequestRepository _repository;

  @override
  Future<Result<MarketingRequestSubmitResult>> call(
    CreateMarketingRequestParams params,
  ) {
    return _repository.createRequest(
      requestType: params.requestType,
      listingAddress: params.listingAddress,
      listingPrice: params.listingPrice,
      notes: params.notes,
      mediaPaths: params.mediaPaths,
    );
  }
}

class CreateMarketingRequestParams extends Equatable {
  const CreateMarketingRequestParams({
    required this.requestType,
    required this.listingAddress,
    required this.listingPrice,
    required this.notes,
    this.mediaPaths = const <String>[],
  });

  final String requestType;
  final String listingAddress;
  final String listingPrice;
  final String notes;
  final List<String> mediaPaths;

  @override
  List<Object?> get props =>
      <Object?>[requestType, listingAddress, listingPrice, notes, mediaPaths];
}
