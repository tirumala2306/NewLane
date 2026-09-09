import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class OfficeScreen extends StatelessWidget {
  const OfficeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileState state = context.watch<ProfileBloc>().state;
    final String officeName = switch (state) {
      ProfileLoaded(:final profile) when profile.officeName.trim().isNotEmpty =>
        profile.officeName.trim(),
      _ => MoreMockData.officeName,
    };

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'OFFICE',
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
            child: SizedBox(
              height: ScreenUtils.h(88),
              child: Center(
                child: AppSvg(
                  AssetConstants.newLaneAppLogo,
                  height: ScreenUtils.h(36),
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(officeName, style: AppTypography.semiBold(fontSize: 16)),
                SizedBox(height: ScreenUtils.h(14)),
                _info(Icons.place_outlined, MoreMockData.officeAddress),
                SizedBox(height: ScreenUtils.h(12)),
                _info(Icons.phone_outlined, MoreMockData.officePhone),
                SizedBox(height: ScreenUtils.h(12)),
                _info(Icons.email_outlined, MoreMockData.officeEmail),
                SizedBox(height: ScreenUtils.h(16)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ScreenUtils.w(12)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        size: ScreenUtils.sp(16),
                        color: AppColors.primaryButtonBg,
                      ),
                      SizedBox(width: ScreenUtils.w(8)),
                      Expanded(
                        child: Text(
                          'This is your assigned office. If you believe this is incorrect, please contact your administrator.',
                          style: AppTypography.regular(
                            fontSize: 11,
                            height: 1.4,
                            color: AppColors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: ScreenUtils.sp(16), color: AppColors.primaryButtonBg),
        SizedBox(width: ScreenUtils.w(8)),
        Expanded(
          child: Text(
            text,
            style: AppTypography.regular(fontSize: 13, height: 1.35),
          ),
        ),
      ],
    );
  }
}
