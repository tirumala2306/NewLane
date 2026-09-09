import 'package:equatable/equatable.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

sealed class MarketingRequestEvent extends Equatable {
  const MarketingRequestEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class MarketingRequestTypeSelected extends MarketingRequestEvent {
  const MarketingRequestTypeSelected(this.type);
  final MarketingRequestType type;

  @override
  List<Object?> get props => <Object?>[type];
}

class MarketingRequestListingSelected extends MarketingRequestEvent {
  const MarketingRequestListingSelected(this.listing);
  final MarketingListing listing;

  @override
  List<Object?> get props => <Object?>[listing];
}

class MarketingRequestAddressChanged extends MarketingRequestEvent {
  const MarketingRequestAddressChanged(this.address);
  final String address;

  @override
  List<Object?> get props => <Object?>[address];
}

class MarketingRequestPriceChanged extends MarketingRequestEvent {
  const MarketingRequestPriceChanged(this.price);
  final String price;

  @override
  List<Object?> get props => <Object?>[price];
}

class MarketingRequestMediaAdded extends MarketingRequestEvent {
  const MarketingRequestMediaAdded(this.paths);
  final List<String> paths;

  @override
  List<Object?> get props => <Object?>[paths];
}

class MarketingRequestMediaRemoved extends MarketingRequestEvent {
  const MarketingRequestMediaRemoved(this.path);
  final String path;

  @override
  List<Object?> get props => <Object?>[path];
}

class MarketingRequestNotesChanged extends MarketingRequestEvent {
  const MarketingRequestNotesChanged(this.notes);
  final String notes;

  @override
  List<Object?> get props => <Object?>[notes];
}

class MarketingRequestNextPressed extends MarketingRequestEvent {
  const MarketingRequestNextPressed();
}

class MarketingRequestBackPressed extends MarketingRequestEvent {
  const MarketingRequestBackPressed();
}

class MarketingRequestSubmitted extends MarketingRequestEvent {
  const MarketingRequestSubmitted();
}
