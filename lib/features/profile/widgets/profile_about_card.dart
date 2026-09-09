import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';

class ProfileAboutCard extends StatelessWidget {
  const ProfileAboutCard({
    required this.about,
    super.key,
  });

  final String about;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('About', style: AppTypography.semiBold(fontSize: 16)),
          SizedBox(height: ScreenUtils.h(10)),
          Text(
            about,
            style: AppTypography.medium(
              fontSize: 10,
              color: AppColors.white.withValues(alpha: 0.7),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
