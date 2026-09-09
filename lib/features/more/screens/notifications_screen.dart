import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'NOTIFICATIONS',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(12),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        itemCount: MoreNotificationsMock.items.length + 1,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: ScreenUtils.h(10)),
        itemBuilder: (BuildContext context, int index) {
          if (index == MoreNotificationsMock.items.length) {
            return UnifiedButton.outline(
              label: 'Load More',
              onPressed: () {},
            );
          }
          final MoreNotificationItem item = MoreNotificationsMock.items[index];
          return MoreCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: ScreenUtils.w(40),
                  height: ScreenUtils.w(40),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButtonBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(18),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTypography.semiBold(
                                fontSize: 13,
                                color: AppColors.primaryButtonBg,
                              ),
                            ),
                          ),
                          Text(
                            item.timeLabel,
                            style: AppTypography.regular(
                              fontSize: 10,
                              color: AppColors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtils.h(6)),
                      Text(
                        item.description,
                        style: AppTypography.regular(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      if (item.isUnread) ...<Widget>[
                        SizedBox(height: ScreenUtils.h(8)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: ScreenUtils.w(8),
                            height: ScreenUtils.w(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryButtonBg,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
