import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/training/data/mock/training_hub_mock_data.dart';
import 'package:newlane/features/training/widgets/training_hub_card.dart';

class TrainingDownloadTile extends StatelessWidget {
  const TrainingDownloadTile({
    required this.file,
    super.key,
    this.onDownload,
  });

  final TrainingDownload file;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return TrainingHubCard(
      onTap: onDownload,
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtils.w(28),
            height: ScreenUtils.w(28),
            decoration: BoxDecoration(
              color: file.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
            ),
            child: Icon(
              file.icon,
              color: file.iconColor,
              size: ScreenUtils.sp(16),
            ),
          ),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  file.fileName,
                  style: AppTypography.semiBold(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScreenUtils.h(2)),
                Text(
                  file.sizeLabel,
                  style: AppTypography.regular(
                    fontSize: 10,
                    color: AppColors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download_rounded,
            color: AppColors.primaryButtonBg,
            size: ScreenUtils.sp(20),
          ),
        ],
      ),
    );
  }
}
