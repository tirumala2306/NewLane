import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/onboarding/widgets/onboarding_feature_list.dart';

class OnboardingSlideTwo extends StatelessWidget {
  const OnboardingSlideTwo({super.key});

  static const List<OnboardingFeatureItem> _features = <OnboardingFeatureItem>[
    OnboardingFeatureItem(
      icon: AssetConstants.chatIcon,
      label: 'Stay Connected',
      description:
          'Chat with your team, share updates, and new miss important news.',
    ),
    OnboardingFeatureItem(
      icon: AssetConstants.notesIcon,
      label: 'Powerful Tools',
      description:
          'Create posts, request marketing support, and access premium resources.',
    ),
    OnboardingFeatureItem(
      icon: AssetConstants.personalIcon,
      label: 'Built for Agents',
      description:
          'Designed by agents, for agents to help you collaborate and succeed together.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: ScreenUtils.h(20)),
          Text('DISCOVER.', style: AppTypography.medium(fontSize: 32)),
          SizedBox(height: ScreenUtils.h(10)),
          Text(
            'CONNECT.',
            style: AppTypography.medium(
              fontSize: 32,
              color: AppColors.primaryButtonBg,
            ),
          ),
          SizedBox(height: ScreenUtils.h(10)),
          Text('GROW.', style: AppTypography.medium(fontSize: 32)),
          SizedBox(height: ScreenUtils.h(18)),
          Container(
            width: ScreenUtils.w(42),
            height: ScreenUtils.h(1),
            color: AppColors.primaryButtonBg,
          ),
          SizedBox(height: ScreenUtils.h(20)),
          SizedBox(
            width: ScreenUtils.w(182),
            height: ScreenUtils.h(72),
            child: Text(
              'Everything you need to run your real estate business, all in one place.',
              style: AppTypography.medium(fontSize: 12, height: 2),
            ),
          ),
          const Spacer(),
          const OnboardingFeatureList(
            items: _features,
            backgroundAsset: AssetConstants.loginBg,
          ),
          SizedBox(height: ScreenUtils.h(50)),
        ],
      ),
    );
  }
}
