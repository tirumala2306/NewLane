import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Horizontal page dots used in onboarding / carousels.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    required this.count,
    required this.index,
    super.key,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: ScreenUtils.w(8)),
          width: ScreenUtils.r(10),
          height: ScreenUtils.r(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryButtonBg
                : AppColors.white.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }
}
