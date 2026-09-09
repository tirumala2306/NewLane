import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    super.key,
    this.onViewAll,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: AppTypography.medium(fontSize: 12),
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtils.h(4),
                horizontal: ScreenUtils.w(2),
              ),
              child: Text(
                'View all',
                style: AppTypography.medium(
                  fontSize: 10,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
