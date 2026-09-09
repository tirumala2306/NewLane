import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/glass_container.dart';

class OnboardingFeatureItem {
  const OnboardingFeatureItem({
    required this.icon,
    required this.label,
    required this.description,
  });

  final String icon;
  final String label;
  final String description;
}

class OnboardingFeatureList extends StatelessWidget {
  const OnboardingFeatureList({
    required this.items,
    super.key,
    this.backgroundAsset,
  });

  final List<OnboardingFeatureItem> items;
  final String? backgroundAsset;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      backgroundAsset: backgroundAsset,
      blurSigma: 30,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(15),
        vertical: ScreenUtils.h(16),
      ),
      child: Column(
        children: List<Widget>.generate(items.length, (int index) {
          final OnboardingFeatureItem item = items[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == items.length - 1 ? 0 : ScreenUtils.h(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSvg(
                  item.icon,
                  width: ScreenUtils.w(40),
                  height: ScreenUtils.h(40),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.label,
                        style: AppTypography.semiBold(fontSize: 14),
                      ),
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        item.description,
                        style: AppTypography.regular(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
