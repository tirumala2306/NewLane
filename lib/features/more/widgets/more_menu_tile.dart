import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_card.dart';

class MoreMenuTile extends StatelessWidget {
  const MoreMenuTile({
    required this.item,
    super.key,
    this.onTap,
  });

  final MoreMenuItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = item.isDestructive
        ? const Color(0xFFFF383C)
        : AppColors.primaryButtonBg;

    return MoreCard(
      onTap: onTap,
      height: ScreenUtils.h(63),
      borderColor: item.isDestructive
          ? const Color(0xFFFF383C).withValues(alpha: 0.35)
          : null,
      child: Row(
        children: <Widget>[
          Icon(item.icon, size: ScreenUtils.sp(30), color: accent),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.semiBold(
                    fontSize: 12,
                    color: item.isDestructive ? accent : AppColors.white,
                  ),
                ),
                if (item.subtitle != null) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(6)),
                  Text(
                    item.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.regular(
                      fontSize: 10,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.trailingText != null) ...<Widget>[
            Text(
              item.trailingText!,
              style: AppTypography.medium(fontSize: 10, color: accent),
            ),
            SizedBox(width: ScreenUtils.w(8)),
          ],
          Icon(
            Icons.chevron_right,
            size: ScreenUtils.sp(20),
            color: accent,
          ),
        ],
      ),
    );
  }
}
