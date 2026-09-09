import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    required this.stats,
    super.key,
  });

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(stats.length, (int index) {
        final ProfileStat stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : ScreenUtils.w(6) / 2,
              right: index == stats.length - 1 ? 0 : ScreenUtils.w(6) / 2,
            ),
            child: HomeCard(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.w(6),
                vertical: ScreenUtils.h(12),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    stat.icon,
                    size: ScreenUtils.sp(18),
                    color: AppColors.primaryButtonBg,
                  ),
                  SizedBox(height: ScreenUtils.h(8)),
                  Text(
                    stat.value,
                    style: AppTypography.semiBold(fontSize: 14),
                  ),
                  SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    stat.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.medium(
                      fontSize: 8,
                      color: AppColors.mutedGrey,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
