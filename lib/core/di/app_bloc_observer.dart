import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/utils/app_log.dart';

/// Prints every bloc create / event / state / error (plain stdout).
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    AppLog.line('[BLOC] created → ${bloc.runtimeType}');
    super.onCreate(bloc);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    AppLog.line('[BLOC] event  → ${bloc.runtimeType} | $event');
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    AppLog.section('BLOC STATE (${bloc.runtimeType})', <String, Object?>{
      'FROM': change.currentState,
      'TO': change.nextState,
    });
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLog.section('BLOC ERROR (${bloc.runtimeType})', <String, Object?>{
      'ERROR': error,
      'STACK': stackTrace,
    });
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    AppLog.line('[BLOC] closed → ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
