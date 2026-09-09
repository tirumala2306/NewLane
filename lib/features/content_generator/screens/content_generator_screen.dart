import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';

class ContentGeneratorScreen extends StatefulWidget {
  const ContentGeneratorScreen({super.key});

  @override
  State<ContentGeneratorScreen> createState() => _ContentGeneratorScreenState();
}

class _ContentGeneratorScreenState extends State<ContentGeneratorScreen> {
  ContentGeneratorType _selected = ContentGeneratorType.socialMediaPost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(context, title: 'CONTENT GENERATOR'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          Text(
            'Create high-quality content in seconds',
            style: AppTypography.semiBold(fontSize: 16, height: 1.3),
          ),
          SizedBox(height: ScreenUtils.h(6)),
          Text(
            'Choose a content type to get started',
            style: AppTypography.regular(
              fontSize: 12,
              color: AppColors.primaryButtonBg,
            ),
          ),
          SizedBox(height: ScreenUtils.h(18)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ScreenUtils.h(10),
            crossAxisSpacing: ScreenUtils.w(10),
            childAspectRatio: 1.05,
            children: ContentGeneratorType.values.map(
              (ContentGeneratorType type) {
                return ContentTypeCard(
                  type: type,
                  selected: _selected == type,
                  onTap: () {
                    setState(() => _selected = type);
                    context.push(
                      AppRoutes.contentGeneratorDetails,
                      extra: ContentGeneratorDraft(type: type),
                    );
                  },
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
