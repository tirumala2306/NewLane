import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        title: 'FEED',
        description: 'UPDATES',
        height: ScreenUtils.h(56),
      ),
      body: Center(
        child: Text(
          'Feed',
          style: AppTypography.medium(fontSize: 16),
        ),
      ),
    );
  }
}
