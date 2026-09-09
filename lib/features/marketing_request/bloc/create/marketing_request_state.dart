import 'package:equatable/equatable.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

class MarketingRequestState extends Equatable {
  const MarketingRequestState({
    this.step = 0,
    this.requestType,
    this.listing,
    this.address = '',
    this.priceDigits = '',
    this.mediaPaths = const <String>[],
    this.notes = '',
    this.submitting = false,
    this.errorMessage,
    this.successMessage,
  });

  static const int lastStep = 3;
  static const int maxMedia = 6;
  static const int maxNotes = 300;

  final int step;
  final MarketingRequestType? requestType;
  final MarketingListing? listing;
  final String address;
  final String priceDigits;
  final List<String> mediaPaths;
  final String notes;
  final bool submitting;
  final String? errorMessage;
  final String? successMessage;

  bool get isReviewStep => step == lastStep;
  bool get canSubmit =>
      (requestType != null) && address.trim().isNotEmpty && !submitting;

  String get formattedPrice {
    if (priceDigits.isEmpty) return '';
    return MarketingListing(
      id: 'price',
      address: address,
      price: int.tryParse(priceDigits) ?? 0,
      title: '',
    ).priceLabel;
  }

  String get nextLabel {
    return switch (step) {
      0 => 'Next: Listing',
      1 => 'Next: Details',
      2 => 'Next: Review',
      _ => 'Submit',
    };
  }

  MarketingRequestState copyWith({
    int? step,
    MarketingRequestType? requestType,
    MarketingListing? listing,
    String? address,
    String? priceDigits,
    List<String>? mediaPaths,
    String? notes,
    bool? submitting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearListing = false,
  }) {
    return MarketingRequestState(
      step: step ?? this.step,
      requestType: requestType ?? this.requestType,
      listing: clearListing ? null : (listing ?? this.listing),
      address: address ?? this.address,
      priceDigits: priceDigits ?? this.priceDigits,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      notes: notes ?? this.notes,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    step,
    requestType,
    listing,
    address,
    priceDigits,
    mediaPaths,
    notes,
    submitting,
    errorMessage,
    successMessage,
  ];
}
