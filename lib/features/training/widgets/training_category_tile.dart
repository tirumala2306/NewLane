import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/widgets/training_hub_card.dart';

class TrainingCategoryTile extends StatelessWidget {
  const TrainingCategoryTile({
    required this.meta,
    super.key,
    this.onTap,
  });

  final TrainingCategoryMeta meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TrainingHubCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            meta.icon,
            size: ScreenUtils.sp(22),
            color: AppColors.primaryButtonBg,
          ),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  meta.title,
                  style: AppTypography.semiBold(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScreenUtils.h(2)),
                Text(
                  meta.subtitle,
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
