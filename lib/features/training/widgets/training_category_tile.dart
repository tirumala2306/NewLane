
import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/training/data/mock/training_hub_mock_data.dart';
import 'package:newlane/features/training/widgets/training_hub_card.dart';

class TrainingCategoryTile extends StatelessWidget {
  const TrainingCategoryTile({
    required this.category,
    super.key,
    this.onTap,
  });

  final TrainingCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TrainingHubCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          _Leading(category: category),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  category.title,
                  style: AppTypography.semiBold(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScreenUtils.h(2)),
                Text(
                  category.subtitle,
                  style: AppTypography.regular(
                    fontSize: 10,
                    height: 1.2,
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: ScreenUtils.w(8)),
          Icon(
            Icons.chevron_right,
            color: AppColors.primaryButtonBg,
            size: ScreenUtils.sp(20),
          ),
        ],
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.category});

  final TrainingCategory category;

  @override
  Widget build(BuildContext context) {
    final double size = ScreenUtils.w(28);
    final double? progress = category.progress;

    if (progress != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 2,
                color: AppColors.primaryButtonBg,
                backgroundColor: AppColors.primaryButtonBg.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            Icon(
              Icons.local_fire_department,
              size: ScreenUtils.sp(12),
              color: AppColors.primaryButtonBg,
            ),
          ],
        ),
      );
    }

    return Icon(
      category.icon,
      size: ScreenUtils.sp(22),
      color: AppColors.primaryButtonBg,
    );
  }
}
