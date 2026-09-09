import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/marketing_request/bloc/create/marketing_request_event.dart';
import 'package:newlane/features/marketing_request/bloc/create/marketing_request_state.dart';
import 'package:newlane/features/marketing_request/domain/usecases/create_marketing_request.dart';

class MarketingRequestBloc
    extends Bloc<MarketingRequestEvent, MarketingRequestState> {
  MarketingRequestBloc({required CreateMarketingRequest createMarketingRequest})
    : _createMarketingRequest = createMarketingRequest,
      super(const MarketingRequestState()) {
    on<MarketingRequestTypeSelected>(_onTypeSelected);
    on<MarketingRequestListingSelected>(_onListingSelected);
    on<MarketingRequestAddressChanged>(_onAddressChanged);
    on<MarketingRequestPriceChanged>(_onPriceChanged);
    on<MarketingRequestMediaAdded>(_onMediaAdded);
    on<MarketingRequestMediaRemoved>(_onMediaRemoved);
    on<MarketingRequestNotesChanged>(_onNotesChanged);
    on<MarketingRequestNextPressed>(_onNextPressed);
    on<MarketingRequestBackPressed>(_onBackPressed);
    on<MarketingRequestSubmitted>(_onSubmitted);
  }

  final CreateMarketingRequest _createMarketingRequest;

  void _onTypeSelected(
    MarketingRequestTypeSelected event,
    Emitter<MarketingRequestState> emit,
  ) {
    emit(state.copyWith(requestType: event.type, clearError: true));
  }

  void _onListingSelected(
    MarketingRequestListingSelected event,
    Emitter<MarketingRequestState> emit,
  ) {
    emit(
      state.copyWith(
        listing: event.listing,
        address: event.listing.address,
        priceDigits: '${event.listing.price}',
        clearError: true,
      ),
    );
  }

  void _onAddressChanged(
    MarketingRequestAddressChanged event,
    Emitter<MarketingRequestState> emit,
  ) {
    emit(state.copyWith(address: event.address, clearError: true));
  }

  void _onPriceChanged(
    MarketingRequestPriceChanged event,
    Emitter<MarketingRequestState> emit,
  ) {
    final String digits = event.price.replaceAll(RegExp(r'[^0-9]'), '');
    emit(state.copyWith(priceDigits: digits, clearError: true));
  }

  void _onMediaAdded(
    MarketingRequestMediaAdded event,
    Emitter<MarketingRequestState> emit,
  ) {
    final List<String> next = List<String>.from(state.mediaPaths);
    for (final String path in event.paths) {
      if (next.length >= MarketingRequestState.maxMedia) break;
      if (path.trim().isNotEmpty && !next.contains(path)) {
        next.add(path);
      }
    }
    emit(state.copyWith(mediaPaths: next, clearError: true));
  }

  void _onMediaRemoved(
    MarketingRequestMediaRemoved event,
    Emitter<MarketingRequestState> emit,
  ) {
    emit(
      state.copyWith(
        mediaPaths: state.mediaPaths
            .where((String path) => path != event.path)
            .toList(),
      ),
    );
  }

  void _onNotesChanged(
    MarketingRequestNotesChanged event,
    Emitter<MarketingRequestState> emit,
  ) {
    final String notes = event.notes.length > MarketingRequestState.maxNotes
        ? event.notes.substring(0, MarketingRequestState.maxNotes)
        : event.notes;
    emit(state.copyWith(notes: notes, clearError: true));
  }

  void _onNextPressed(
    MarketingRequestNextPressed event,
    Emitter<MarketingRequestState> emit,
  ) {
    final String? error = _validateStep(state.step);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }
    if (state.step >= MarketingRequestState.lastStep) {
      add(const MarketingRequestSubmitted());
      return;
    }
    emit(state.copyWith(step: state.step + 1, clearError: true));
  }

  void _onBackPressed(
    MarketingRequestBackPressed event,
    Emitter<MarketingRequestState> emit,
  ) {
    if (state.step <= 0) return;
    emit(state.copyWith(step: state.step - 1, clearError: true));
  }

  Future<void> _onSubmitted(
    MarketingRequestSubmitted event,
    Emitter<MarketingRequestState> emit,
  ) async {
    final String? error = _validateStep(0) ?? _validateStep(1);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true, clearSuccess: true));
    AppLog.line('[BLOC] marketing request submit type=${state.requestType}');

    final result = await _createMarketingRequest(
      CreateMarketingRequestParams(
        requestType: state.requestType!.label,
        listingAddress: state.address.trim(),
        listingPrice: state.priceDigits,
        notes: state.notes.trim(),
        mediaPaths: state.mediaPaths,
      ),
    );

    result.when(
      ok: (value) {
        emit(
          state.copyWith(
            submitting: false,
            successMessage: value.message.isEmpty
                ? 'Marketing request submitted.'
                : value.message,
          ),
        );
      },
      err: (failure) {
        emit(
          state.copyWith(submitting: false, errorMessage: failure.message),
        );
      },
    );
  }

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (state.requestType == null) {
          return 'Select a request type to continue.';
        }
        return null;
      case 1:
        if (state.address.trim().isEmpty) {
          return 'Enter or select a listing address.';
        }
        return null;
      default:
        return null;
    }
  }
}
