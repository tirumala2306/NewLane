import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'ABOUT NEWLANE',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(12),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          MoreCard(
            child: Column(
              children: <Widget>[
                AppSvg(
                  AssetConstants.newLaneAppLogo,
                  height: ScreenUtils.h(36),
                ),
                SizedBox(height: ScreenUtils.h(12)),
                Text(
                  MoreMockData.aboutVersion,
                  style: AppTypography.regular(
                    fontSize: 11,
                    color: AppColors.white.withValues(alpha: 0.55),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(14)),
                Text(
                  'NewLane is a modern real estate brokerage platform designed to keep agents connected, informed, and engaged — with tools for collaboration, marketing, training, and growth.',
                  textAlign: TextAlign.center,
                  style: AppTypography.regular(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MoreCard(
            child: Column(
              children: <Widget>[
                MoreNavRow(
                  title: 'Contact Us',
                  onTap: () => _openUrl('mailto:gabrielr@marsblue.co'),
                ),
                moreDivider(),
                MoreNavRow(
                  title: 'Visit Website',
                  onTap: () => _openUrl('https://newlane.com'),
                ),
                moreDivider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Follow Us',
                        style: AppTypography.semiBold(fontSize: 13),
                      ),
                    ),
                    Icon(
                      Icons.facebook,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(20),
                    ),
                    SizedBox(width: ScreenUtils.w(12)),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(20),
                    ),
                    SizedBox(width: ScreenUtils.w(12)),
                    Icon(
                      Icons.business_center_outlined,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MoreCard(
            child: Center(
              child: Text(
                '© 2024 NewLane. All rights reserved.',
                style: AppTypography.regular(
                  fontSize: 11,
                  color: AppColors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
