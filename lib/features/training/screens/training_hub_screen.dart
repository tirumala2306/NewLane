import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/features/training/data/mock/training_hub_mock_data.dart';
import 'package:newlane/features/training/widgets/training_category_tile.dart';
import 'package:newlane/features/training/widgets/training_download_tile.dart';
import 'package:newlane/features/training/widgets/training_onboarding_banner.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String officeName = switch (profileState) {
      ProfileLoaded(:final profile) when profile.officeName.trim().isNotEmpty =>
        profile.officeName.trim().toUpperCase(),
      _ => HomeMockData.officeName.toUpperCase(),
    };

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        prefixIconColor: AppColors.primaryButtonBg,
        onPrefixPressed: () => context.pop(),
        title: 'TRAINING HUB',
        titleFontSize: 16,
        description: officeName,
        descriptionFontSize: 10,
        suffix: IconButton(
          onPressed: () {},
          icon: Icon(
            CupertinoIcons.bell,
            size: ScreenUtils.sp(22),
            color: AppColors.primaryButtonBg,
          ),
        ),
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          ...List<Widget>.generate(
            TrainingHubMockData.categories.length,
            (int index) {
              final TrainingCategory category =
                  TrainingHubMockData.categories[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: ScreenUtils.h(10),
                ),
                child: TrainingCategoryTile(category: category),
              );
            },
          ),
          const TrainingOnboardingBanner(
            title: TrainingHubMockData.onboardingTitle,
            subtitle: TrainingHubMockData.onboardingSubtitle,
            imageUrl: TrainingHubMockData.onboardingImageUrl,
          ),
          SizedBox(height: ScreenUtils.h(20)),
          _DownloadsHeader(onViewAll: () {}),
          SizedBox(height: ScreenUtils.h(10)),
          ...List<Widget>.generate(
            TrainingHubMockData.downloads.length,
            (int index) {
              final TrainingDownload file =
                  TrainingHubMockData.downloads[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < TrainingHubMockData.downloads.length - 1
                      ? ScreenUtils.h(10)
                      : 0,
                ),
                child: TrainingDownloadTile(file: file),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DownloadsHeader extends StatelessWidget {
  const _DownloadsHeader({this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Downloads',
            style: AppTypography.semiBold(fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'View All',
                style: AppTypography.medium(
                  fontSize: 12,
                  color: AppColors.primaryButtonBg,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: ScreenUtils.sp(18),
                color: AppColors.primaryButtonBg,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
