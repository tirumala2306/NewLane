import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Lightweight shimmer-ish block for section/content skeletons.
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(
          borderRadius ?? ScreenUtils.r(8),
        ),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.04)),
      ),
    );
  }
}

class FeedPostCardSkeleton extends StatelessWidget {
  const FeedPostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(ScreenUtils.r(12)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppSkeletonBox(
                width: ScreenUtils.w(40),
                height: ScreenUtils.w(40),
                borderRadius: ScreenUtils.r(20),
              ),
              SizedBox(width: ScreenUtils.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppSkeletonBox(
                      width: ScreenUtils.w(120),
                      height: ScreenUtils.h(12),
                    ),
                    SizedBox(height: ScreenUtils.h(6)),
                    AppSkeletonBox(
                      width: ScreenUtils.w(80),
                      height: ScreenUtils.h(10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.h(12)),
          AppSkeletonBox(
            width: double.infinity,
            height: ScreenUtils.h(12),
          ),
          SizedBox(height: ScreenUtils.h(8)),
          AppSkeletonBox(
            width: ScreenUtils.w(200),
            height: ScreenUtils.h(12),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          AppSkeletonBox(
            width: double.infinity,
            height: ScreenUtils.h(160),
          ),
        ],
      ),
    );
  }
}

class ProfileListingsSkeleton extends StatelessWidget {
  const ProfileListingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        border: Border.all(
          color: AppColors.primaryButtonBg.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppSkeletonBox(
                width: ScreenUtils.w(110),
                height: ScreenUtils.h(14),
              ),
              const Spacer(),
              AppSkeletonBox(
                width: ScreenUtils.w(48),
                height: ScreenUtils.h(12),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.h(12)),
          SizedBox(
            height: ScreenUtils.h(196),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => SizedBox(width: ScreenUtils.w(10)),
              itemBuilder: (_, _) => AppSkeletonBox(
                width: ScreenUtils.w(148),
                height: ScreenUtils.h(196),
                borderRadius: ScreenUtils.r(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
