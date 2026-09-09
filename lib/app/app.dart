import 'package:flutter/material.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/router/app_router.dart';
import 'package:newlane/core/theme/app_theme.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/environment_banner.dart';

class NewLaneApp extends StatelessWidget {
  const NewLaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (BuildContext context, Widget? child) {
        ScreenUtils.init(context);
        return EnvironmentBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
