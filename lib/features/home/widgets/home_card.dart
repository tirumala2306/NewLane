import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Shared dark surface card used across home sections.
class HomeCard extends StatelessWidget {
  const HomeCard({
    required this.child,
    super.key,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  static BorderRadius get radius =>
      BorderRadius.circular(ScreenUtils.r(8));

  static Color get borderColor =>
      AppColors.primaryButtonBg.withValues(alpha: 0.05);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(ScreenUtils.w(16)),
      decoration: BoxDecoration(
        color: const Color(0XFF090909),
        borderRadius: radius,
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
