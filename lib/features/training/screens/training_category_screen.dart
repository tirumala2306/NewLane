import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/training/bloc/training_bloc.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/utils/training_resource_actions.dart';
import 'package:newlane/features/training/widgets/training_download_tile.dart';
import 'package:newlane/shared/widgets/app_skeleton.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class TrainingCategoryScreen extends StatelessWidget {
  const TrainingCategoryScreen({
    required this.apiCategory,
    required this.title,
    super.key,
  });

  final String apiCategory;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        prefixIconColor: AppColors.primaryButtonBg,
        onPrefixPressed: () => context.pop(),
        title: title.toUpperCase(),
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: BlocBuilder<TrainingBloc, TrainingState>(
        builder: (BuildContext context, TrainingState state) {
          if (state is TrainingLoading || state is TrainingInitial) {
            return ListView(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(12),
                ScreenUtils.w(16),
                ScreenUtils.h(32),
              ),
              children: List<Widget>.generate(
                4,
                (int i) => Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
                  child: AppSkeletonBox(
                    width: double.infinity,
                    height: ScreenUtils.h(63),
                  ),
                ),
              ),
            );
          }
          if (state is TrainingError) {
            return _CategoryEmpty(
              icon: Icons.wifi_off_rounded,
              title: 'Couldn’t load resources',
              message: state.message,
            );
          }
          if (state is! TrainingLoaded) {
            return const SizedBox.shrink();
          }

          final List<TrainingResource> items = state.byCategory(apiCategory);
          if (items.isEmpty) {
            return _CategoryEmpty(
              icon: Icons.folder_open_outlined,
              title: 'Nothing here yet',
              message:
                  'No $title resources have been published. Pull to refresh or check back later.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(12),
              ScreenUtils.w(16),
              ScreenUtils.h(32),
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: ScreenUtils.h(10)),
            itemBuilder: (BuildContext context, int index) {
              final TrainingResource resource = items[index];
              return TrainingDownloadTile(
                resource: resource,
                onOpen: () => handleTrainingPlay(context, resource),
                onDownload: () => handleTrainingDownload(context, resource),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryEmpty extends StatelessWidget {
  const _CategoryEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: ScreenUtils.w(64),
              height: ScreenUtils.w(64),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryButtonBg.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primaryButtonBg.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                icon,
                size: ScreenUtils.sp(28),
                color: AppColors.primaryButtonBg,
              ),
            ),
            SizedBox(height: ScreenUtils.h(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.semiBold(fontSize: 16),
            ),
            SizedBox(height: ScreenUtils.h(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 13,
                height: 1.4,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
