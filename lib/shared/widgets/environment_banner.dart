import 'package:flutter/material.dart';
import 'package:newlane/core/config/app_environment.dart';

class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppEnvironment.showEnvironmentBanner) {
      return child;
    }

    return Banner(
      message: AppEnvironment.name.toUpperCase(),
      location: BannerLocation.topEnd,
      child: child,
    );
  }
}
