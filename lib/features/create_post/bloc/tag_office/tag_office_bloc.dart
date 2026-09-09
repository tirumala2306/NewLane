import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_event.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_state.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/create_post/domain/usecases/get_offices.dart';

class TagOfficeBloc extends Bloc<TagOfficeEvent, TagOfficeState> {
  TagOfficeBloc({required GetOffices getOffices})
    : _getOffices = getOffices,
      super(const TagOfficeInitial()) {
    on<TagOfficeStarted>(_onStarted);
    on<TagOfficeSearchChanged>(_onSearchChanged);
    on<TagOfficeSelected>(_onSelected);
  }

  final GetOffices _getOffices;
  String _query = '';
  int? _selectedOfficeId;
  List<Office> _offices = const <Office>[];

  Future<void> _onStarted(
    TagOfficeStarted event,
    Emitter<TagOfficeState> emit,
  ) async {
    _selectedOfficeId = event.selectedOfficeId;
    await _load(emit);
  }

  Future<void> _onSearchChanged(
    TagOfficeSearchChanged event,
    Emitter<TagOfficeState> emit,
  ) async {
    _query = event.query.trim();
    await _load(emit);
  }

  void _onSelected(TagOfficeSelected event, Emitter<TagOfficeState> emit) {
    _selectedOfficeId = event.officeId;
    emit(
      TagOfficeLoaded(
        offices: _offices,
        query: _query,
        selectedOfficeId: _selectedOfficeId,
      ),
    );
  }

  Future<void> _load(Emitter<TagOfficeState> emit) async {
    emit(
      TagOfficeLoading(
        previousOffices: _offices.isEmpty ? null : _offices,
        selectedOfficeId: _selectedOfficeId,
      ),
    );

    final result = await _getOffices(GetOfficesParams(search: _query));
    result.when(
      ok: (List<Office> offices) {
        _offices = offices;
        emit(
          TagOfficeLoaded(
            offices: offices,
            query: _query,
            selectedOfficeId: _selectedOfficeId,
          ),
        );
      },
      err: (failure) {
        emit(
          TagOfficeFailure(
            message: failure.message,
            previousOffices: _offices.isEmpty ? null : _offices,
            selectedOfficeId: _selectedOfficeId,
          ),
        );
      },
    );
  }
}
