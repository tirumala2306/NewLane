import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/features/training/data/mock/training_hub_mock_data.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/widgets/training_category_tile.dart';
import 'package:newlane/features/training/widgets/training_hub_card.dart';
import 'package:newlane/features/training/widgets/training_onboarding_banner.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

/// Training Hub — fixed design layout (categories + banner + downloads).
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
          onPressed: () => context.push(AppRoutes.moreNotifications),
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
          ...List<Widget>.generate(TrainingHubCatalog.categories.length, (
            int i,
          ) {
            final TrainingCategoryMeta meta =
                TrainingHubCatalog.categories[i];
            return Padding(
              padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
              child: TrainingCategoryTile(
                meta: meta,
                onTap: () {
                  context.push(
                    AppRoutes.trainingCategory(meta.apiCategory),
                    extra: meta.title,
                  );
                },
              ),
            );
          }),
          TrainingOnboardingBanner(
            title: TrainingHubMockData.onboardingTitle,
            subtitle: TrainingHubMockData.onboardingSubtitle,
            onWatchNow: () {
              context.push(
                AppRoutes.trainingCategory('Video'),
                extra: 'Videos',
              );
            },
          ),
          SizedBox(height: ScreenUtils.h(20)),
          const _DownloadsHeader(),
          SizedBox(height: ScreenUtils.h(10)),
          ...List<Widget>.generate(TrainingHubMockData.downloads.length, (
            int index,
          ) {
            final TrainingDownload file =
                TrainingHubMockData.downloads[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < TrainingHubMockData.downloads.length - 1
                    ? ScreenUtils.h(10)
                    : 0,
              ),
              child: _StaticDownloadTile(file: file),
            );
          }),
        ],
      ),
    );
  }
}

class _DownloadsHeader extends StatelessWidget {
  const _DownloadsHeader();

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
          onTap: () {
            context.push(
              AppRoutes.trainingCategory('PDF'),
              extra: 'PDFs',
            );
          },
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

class _StaticDownloadTile extends StatelessWidget {
  const _StaticDownloadTile({required this.file});

  final TrainingDownload file;

  void _toast(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    AppSnackBar.showInfo(context, title: title, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return TrainingHubCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toast(
                  context,
                  title: 'View',
                  message:
                      '${file.fileName} — open from PDFs when published.',
                ),
                borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtils.w(28),
                      height: ScreenUtils.w(28),
                      decoration: BoxDecoration(
                        color: file.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                      ),
                      child: Icon(
                        file.icon,
                        color: file.iconColor,
                        size: ScreenUtils.sp(16),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(10)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            file.fileName,
                            style: AppTypography.semiBold(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ScreenUtils.h(2)),
                          Text(
                            file.sizeLabel,
                            style: AppTypography.regular(
                              fontSize: 10,
                              color: AppColors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toast(
                context,
                title: 'View',
                message: '${file.fileName} — open from PDFs when published.',
              ),
              borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtils.w(6)),
                child: Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primaryButtonBg,
                  size: ScreenUtils.sp(20),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toast(
                context,
                title: 'Download',
                message:
                    '${file.fileName} — download from PDFs when published.',
              ),
              borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtils.w(6)),
                child: Icon(
                  Icons.download_rounded,
                  color: AppColors.primaryButtonBg,
                  size: ScreenUtils.sp(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
