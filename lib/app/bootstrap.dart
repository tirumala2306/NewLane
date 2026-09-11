import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

    try {
      await AppEnvironment.initialize();
      AppEnvironment.validate();
    } catch (error, stack) {
      // Avoid blank white screen if env/dart-defines are missing.
      AppLog.section('ENV INIT FAILED', <String, Object?>{
        'ERROR': error,
        'STACK': stack,
      });
      runApp(_BootstrapErrorApp(message: error.toString()));
      return;
    }

    AppLog.section('APP START', <String, Object?>{
      'ENV': AppEnvironment.name,
      'BASE_URL': AppEnvironment.baseUrl,
    });

    await FirebaseBootstrap.init();
    await InjectionContainer.instance.init();

    await DeepLinkHandler.init(AppRouter.router);

    // Phase 2: FCM permission + token listeners (token sync after login).
    await InjectionContainer.instance.pushNotificationService.init();

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

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'App failed to start.\n\n$message',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
