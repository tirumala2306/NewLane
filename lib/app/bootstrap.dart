import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/app/app.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/deep_links/deep_link_handler.dart';
import 'package:newlane/core/di/app_bloc_observer.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/firebase/firebase_bootstrap.dart';
import 'package:newlane/core/router/app_router.dart';
import 'package:newlane/core/utils/app_log.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();
    _configureErrorHandling();

    Bloc.observer = AppBlocObserver();

    await AppEnvironment.initialize();
    AppEnvironment.validate();

    AppLog.section('APP START', <String, Object?>{
      'ENV': AppEnvironment.name,
      'BASE_URL': AppEnvironment.baseUrl,
    });

    await FirebaseBootstrap.init();
    await InjectionContainer.instance.init();

    await DeepLinkHandler.init(AppRouter.router);

    runApp(const NewLaneApp());
  }

  static void _configureErrorHandling() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLog.section('FLUTTER ERROR', <String, Object?>{
        'EXCEPTION': details.exception,
        'LIBRARY': details.library,
      });
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      AppLog.section('UNHANDLED ERROR', <String, Object?>{
        'ERROR': error,
        'STACK': stackTrace,
      });
      return true;
    };
  }
}
