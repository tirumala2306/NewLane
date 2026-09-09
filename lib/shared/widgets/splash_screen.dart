import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;

    final di = InjectionContainer.instance;
    final storage = di.appStorage;

    // Older installs may have token / request / email but no onboarding flag.
    await storage.syncOnboardingFromLocalData();
    if (!mounted) return;

    final String next;
    if (di.isLoggedIn) {
      next = AppRoutes.home;
    } else if (storage.hasLocalUserData || storage.hasCompletedOnboarding) {
      // Local details exist → never show onboarding again.
      next = AppRoutes.signIn;
    } else {
      // Fresh install / empty local storage only.
      next = AppRoutes.onboarding;
    }

    AppLog.line(
      '[SPLASH] → $next '
      '(loggedIn=${di.isLoggedIn}, '
      'onboarding=${storage.hasCompletedOnboarding}, '
      'localData=${storage.hasLocalUserData})',
    );
    context.go(next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(
        child: AppSvg(
          AssetConstants.splashImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
