import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/onboarding/widgets/onboarding_feature_list.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class OnboardingSlideThree extends StatelessWidget {
  const OnboardingSlideThree({super.key});

  static const List<OnboardingFeatureItem> _features = <OnboardingFeatureItem>[
    OnboardingFeatureItem(
      icon: AssetConstants.privateIcon,
      label: 'Enterprise Security',
      description: 'Bank-level encryption keeps your data safe.',
    ),
    OnboardingFeatureItem(
      icon: AssetConstants.lockIcon,
      label: 'Private Network',
      description: 'Connect only with verified agents and teams.',
    ),
    OnboardingFeatureItem(
      icon: AssetConstants.eyeClosedIcon,
      label: "You're in Control",
      description: 'Manage your data and privacy settings anytime.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // Shield — top-right (Figma 292 x 425), past content padding to screen edge.
        Positioned(
          right: ScreenUtils.w(-46),
          left: ScreenUtils.w(-98),
          child: IgnorePointer( 
            child: AppSvg(
              AssetConstants.onboardingSecurityBg,
              width: ScreenUtils.w(292),
              height: ScreenUtils.h(500),
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: ScreenUtils.h(20)),
              Text('SECURE.', style: AppTypography.medium(fontSize: 32)),
              SizedBox(height: ScreenUtils.h(10)),
              Text(
                'PRIVATE.',
                style: AppTypography.medium(
                  fontSize: 32,
                  color: AppColors.primaryButtonBg,
                ),
              ),
              SizedBox(height: ScreenUtils.h(10)),
              Text('YOURS.', style: AppTypography.medium(fontSize: 32)),
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
                  'Your data and conversations are always protected.We prioritize your privacy so you can focus on what matters.',
                  style: AppTypography.medium(fontSize: 12, height: 2),
                ),
              ),
              const Spacer(),
              const OnboardingFeatureList(
                items: _features,
                backgroundAsset: AssetConstants.onboardingSecurityBg,
              ),
              SizedBox(height: ScreenUtils.h(50)),
            ],
          ),
        ),
      ],
    );
  }
}
