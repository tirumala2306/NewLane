import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

class MoreProfileHeader extends StatelessWidget {
  const MoreProfileHeader({
    super.key,
    this.name = '',
    this.avatarUrl,
    this.isLoading = false,
    this.onViewProfile,
  });

  final String name;
  final String? avatarUrl;
  final bool isLoading;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    final String displayName =
        name.trim().isEmpty ? 'Your Profile' : name.trim();

    return MoreCard(
      child: Row(
        children: <Widget>[
          ProfileAvatar(url: avatarUrl, size: ScreenUtils.w(52)),
          SizedBox(width: ScreenUtils.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isLoading ? 'Loading…' : displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.semiBold(fontSize: 14),
                ),
                SizedBox(height: ScreenUtils.h(6)),
                GestureDetector(
                  onTap: onViewProfile,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'View Profile >',
                    style: AppTypography.semiBold(
                      fontSize: 11,
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ScreenUtils.w(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.w(10),
              vertical: ScreenUtils.h(8),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
              border: Border.all(color: MoreCard.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.star,
                  size: ScreenUtils.sp(14),
                  color: AppColors.primaryButtonBg,
                ),
                SizedBox(width: ScreenUtils.w(4)),
                Text(
                  '${MoreMockData.points} Points',
                  style: AppTypography.medium(
                    fontSize: 11,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
