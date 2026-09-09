import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';

class SupportNeedHelpCard extends StatelessWidget {
  const SupportNeedHelpCard({super.key, this.onCallTap});

  final VoidCallback? onCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: HomeCard.radius,
        border: Border.all(
          color: AppColors.primaryButtonBg.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtils.w(44),
            height: ScreenUtils.w(44),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
              border: Border.all(color: AppColors.primaryButtonBg),
            ),
            child: Icon(
              Icons.support_agent_outlined,
              size: ScreenUtils.sp(30),
              color: AppColors.primaryButtonBg,
            ),
          ),
          SizedBox(width: ScreenUtils.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Still need help?',
                  style: AppTypography.semiBold(fontSize: 12),
                ),
                SizedBox(height: ScreenUtils.h(6)),
                Text(
                  'Our team typically replies within 2 hours during business hours.',
                  style: AppTypography.medium(
                    fontSize: 9,
                    height: 1.5,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ScreenUtils.w(35)),
          _CallButton(onTap: onCallTap),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          padding: EdgeInsets.all(ScreenUtils.w(6)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.primaryButtonBg.withValues(alpha: 0.25)),
            color: AppColors.primaryButtonBg.withValues(alpha: 0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.phone_outlined,
                size: ScreenUtils.sp(16),
                color: AppColors.primaryButtonBg,
              ),
              SizedBox(width: ScreenUtils.w(4)),
              Text(
                'Call Us',
                style: AppTypography.medium(
                  fontSize: 10,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
