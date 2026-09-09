import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_event.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_state.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/domain/usecases/get_marketing_requests.dart';

class MyRequestsBloc extends Bloc<MyRequestsEvent, MyRequestsState> {
  MyRequestsBloc({required GetMarketingRequests getMarketingRequests})
    : _getMarketingRequests = getMarketingRequests,
      super(const MyRequestsInitial()) {
    on<MyRequestsStarted>(_onStarted);
    on<MyRequestsTabChanged>(_onTabChanged);
    on<MyRequestsSearchChanged>(_onSearchChanged);
    on<MyRequestsRefreshed>(_onRefreshed);
  }

  final GetMarketingRequests _getMarketingRequests;
  bool _showCompleted = false;
  String _search = '';

  Future<void> _onStarted(
    MyRequestsStarted event,
    Emitter<MyRequestsState> emit,
  ) {
    return _load(emit);
  }

  Future<void> _onTabChanged(
    MyRequestsTabChanged event,
    Emitter<MyRequestsState> emit,
  ) {
    _showCompleted = event.completed;
    return _load(emit);
  }

  Future<void> _onSearchChanged(
    MyRequestsSearchChanged event,
    Emitter<MyRequestsState> emit,
  ) async {
    _search = event.query.trim();
    final List<MarketingRequest> current = _currentRequests();
    emit(
      MyRequestsLoaded(
        requests: current,
        showCompleted: _showCompleted,
        search: _search,
      ),
    );
  }

  Future<void> _onRefreshed(
    MyRequestsRefreshed event,
    Emitter<MyRequestsState> emit,
  ) {
    return _load(emit);
  }

  List<MarketingRequest> _currentRequests() {
    return switch (state) {
      MyRequestsLoaded(:final List<MarketingRequest> requests) => requests,
      MyRequestsLoading(:final List<MarketingRequest> previous) => previous,
      MyRequestsFailure(:final List<MarketingRequest> previous) => previous,
      _ => const <MarketingRequest>[],
    };
  }

  Future<void> _load(Emitter<MyRequestsState> emit) async {
    final List<MarketingRequest> previous = _currentRequests();
    emit(
      MyRequestsLoading(
        previous: previous,
        showCompleted: _showCompleted,
        search: _search,
      ),
    );
    AppLog.line(
      '[BLOC] my requests load status=${_showCompleted ? 'completed' : 'active'}',
    );

    final result = await _getMarketingRequests(
      GetMarketingRequestsParams(
        status: _showCompleted ? 'completed' : 'active',
        search: _search,
      ),
    );
    result.when(
      ok: (List<MarketingRequest> requests) {
        emit(
          MyRequestsLoaded(
            requests: requests,
            showCompleted: _showCompleted,
            search: _search,
          ),
        );
      },
      err: (failure) {
        emit(
          MyRequestsFailure(
            failure.message,
            previous: previous,
            showCompleted: _showCompleted,
            search: _search,
          ),
        );
      },
    );
  }
}
