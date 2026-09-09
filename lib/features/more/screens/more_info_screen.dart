import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/more_info_content.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class MoreInfoScreen extends StatelessWidget {
  const MoreInfoScreen({required this.content, super.key});

  final MoreInfoContent content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: content.appBarTitle,
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(24),
          ScreenUtils.h(16),
          ScreenUtils.w(24),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          Text(
            content.heading,
            style: AppTypography.semiBold(fontSize: 20),
          ),
          SizedBox(height: ScreenUtils.h(8)),
          Container(
            width: ScreenUtils.w(42),
            height: ScreenUtils.h(2),
            color: AppColors.primaryButtonBg,
          ),
          SizedBox(height: ScreenUtils.h(20)),
          ...content.sections.expand(_buildSection),
        ],
      ),
    );
  }

  List<Widget> _buildSection(MoreInfoSection section) {
    return <Widget>[
      ...section.paragraphs.map(
        (String text) => Padding(
          padding: EdgeInsets.only(bottom: ScreenUtils.h(14)),
          child: Text(
            text,
            style: AppTypography.medium(
              fontSize: 14,
              height: 1.5,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
      if (section.bullets.isNotEmpty)
        ...section.bullets.map(
          (String bullet) => Padding(
            padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtils.h(6)),
                  child: Container(
                    width: ScreenUtils.w(5),
                    height: ScreenUtils.w(5),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryButtonBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(10)),
                Expanded(
                  child: Text(
                    bullet,
                    style: AppTypography.medium(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (section.footer != null)
        Padding(
          padding: EdgeInsets.only(top: ScreenUtils.h(8), bottom: ScreenUtils.h(16)),
          child: Text(
            section.footer!,
            style: AppTypography.medium(
              fontSize: 14,
              height: 1.5,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ),
    ];
  }
}
