import 'package:equatable/equatable.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

sealed class MyRequestsState extends Equatable {
  const MyRequestsState({
    this.showCompleted = false,
    this.search = '',
  });

  final bool showCompleted;
  final String search;

  @override
  List<Object?> get props => <Object?>[showCompleted, search];
}

class MyRequestsInitial extends MyRequestsState {
  const MyRequestsInitial();
}

class MyRequestsLoading extends MyRequestsState {
  const MyRequestsLoading({
    this.previous = const <MarketingRequest>[],
    super.showCompleted,
    super.search,
  });

  final List<MarketingRequest> previous;

  @override
  List<Object?> get props => <Object?>[previous, showCompleted, search];
}

class MyRequestsLoaded extends MyRequestsState {
  const MyRequestsLoaded({
    required this.requests,
    super.showCompleted,
    super.search,
  });

  final List<MarketingRequest> requests;

  List<MarketingRequest> get visible {
    final String query = search.trim().toLowerCase();
    if (query.isEmpty) return requests;
    return requests.where((MarketingRequest item) {
      return item.requestType.label.toLowerCase().contains(query) ||
          item.listingAddress.toLowerCase().contains(query) ||
          item.status.label.toLowerCase().contains(query);
    }).toList();
  }

  @override
  List<Object?> get props => <Object?>[requests, showCompleted, search];
}

class MyRequestsFailure extends MyRequestsState {
  const MyRequestsFailure(
    this.message, {
    this.previous = const <MarketingRequest>[],
    super.showCompleted,
    super.search,
  });

  final String message;
  final List<MarketingRequest> previous;

  @override
  List<Object?> get props =>
      <Object?>[message, previous, showCompleted, search];
}
