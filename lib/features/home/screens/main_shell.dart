import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/shared/widgets/custom_bottom_nav_bar.dart';

/// Shell that hosts tab branches with [CustomBottomNavBar].
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onItemSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: navigationShell,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onItemSelected: _onItemSelected,
          onCenterTap: () => context.push(AppRoutes.createPost),
        ),
      ),
    );
  }
}
