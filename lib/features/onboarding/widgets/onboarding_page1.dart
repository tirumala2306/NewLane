import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class OnboardingSlideOne extends StatelessWidget {
  const OnboardingSlideOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const AppSvg(AssetConstants.newLaneAppLogo),
          SizedBox(height: ScreenUtils.h(24)),
          Text(
            'ELEVATE. CONNECT. SUCCEED.',
            textAlign: TextAlign.center,
            style: AppTypography.medium(color: AppColors.primaryButtonBg),
          ),
          SizedBox(height: ScreenUtils.h(24)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(10)),
            child: Text.rich(
              TextSpan(
                style: AppTypography.medium(),
                children: <TextSpan>[
                  const TextSpan(text: 'A modern real estate ecosystem built '),
                  TextSpan(
                    text: 'for agents, by agents.',
                    style: AppTypography.medium(
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
