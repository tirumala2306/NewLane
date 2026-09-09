import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class OfficeDirectoryInviteCard extends StatelessWidget {
  const OfficeDirectoryInviteCard({super.key, this.onInvite});

  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        border: Border.all(color: AppColors.primaryButtonBg.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtils.w(34),
            height: ScreenUtils.w(34),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
              border: Border.all(color: AppColors.primaryButtonBg),
            ),
            child: Icon(
              Icons.person_add_alt_1_outlined,
              color: AppColors.primaryButtonBg,
              size: ScreenUtils.sp(22),
            ),
          ),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Can't find someone?",
                  style: AppTypography.medium(
                    fontSize: 10,
                    height: 1.3,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: ScreenUtils.h(4)),
                Text(
                  "Invite a team member to the directory.",
                  style: AppTypography.medium(
                    fontSize: 8,
                    height: 1.3,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          OutlinedButton(
            onPressed: onInvite,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryButtonBg,
              side: const BorderSide(color: AppColors.primaryButtonBg),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.w(12),
                vertical: ScreenUtils.h(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
              ),
            ),
            child: Text(
              'Invite Member',
              style: AppTypography.medium(
                fontSize: 10,
                color: AppColors.primaryButtonBg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
