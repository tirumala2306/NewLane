import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';

class MyRequestsSummary extends StatelessWidget {
  const MyRequestsSummary({
    required this.stats,
    super.key,
    this.onStatTap,
  });

  final List<HomeRequestStat> stats;
  final ValueChanged<HomeRequestStat>? onStatTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(stats.length, (int index) {
        final HomeRequestStat stat = stats[index];
        return Expanded(
          child: Row(
            children: <Widget>[
              if (index > 0)
                Container(
                  width: 1,
                  height: ScreenUtils.h(40),
                  margin: EdgeInsets.symmetric(horizontal: ScreenUtils.w(6)),
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
              Expanded(
                child: InkWell(
                  onTap: onStatTap == null ? null : () => onStatTap!(stat),
                  borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _StatIcon(icon: stat.icon),
                      SizedBox(width: ScreenUtils.w(8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${stat.count}',
                              style: AppTypography.semiBold(
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: ScreenUtils.h(4)),
                            Text(
                              stat.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.regular(
                                fontSize: 8,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(32),
      height: ScreenUtils.w(32),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonBg.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: ScreenUtils.sp(16),
        color: AppColors.primaryButtonBg,
      ),
    );
  }
}
