import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_stepper.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';
import 'package:newlane/features/content_generator/widgets/content_preview_cards.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class ContentPreviewScreen extends StatefulWidget {
  const ContentPreviewScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  State<ContentPreviewScreen> createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  late ContentGeneratorDraft _draft;
  bool _postPreview = true;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  void _regenerate() {
    context.pushReplacement(
      AppRoutes.contentGeneratorGenerating,
      extra: _draft,
    );
  }

  Future<void> _edit() async {
    final ContentEditResult? result = await context.push<ContentEditResult>(
      AppRoutes.contentGeneratorEdit,
      extra: _draft,
    );
    if (result == null || !mounted) {
      return;
    }
    if (result.regenerate) {
      context.pushReplacement(
        AppRoutes.contentGeneratorGenerating,
        extra: result.draft,
      );
      return;
    }
    setState(() {
      _draft = result.draft;
      _postPreview = false;
    });
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: _draft.generatedText));
    if (!mounted) {
      return;
    }
    AppSnackBar.showSuccess(
      context,
      title: 'Copied',
      message: 'Caption copied to clipboard.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(context, title: 'CONTENT PREVIEW'),
      body: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtils.h(8)),
          const ContentGeneratorStepper(currentStep: 4),
          SizedBox(height: ScreenUtils.h(16)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(22),
                    ),
                    SizedBox(width: ScreenUtils.w(8)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Your content is ready!',
                            style: AppTypography.semiBold(fontSize: 14),
                          ),
                          SizedBox(height: ScreenUtils.h(4)),
                          Text(
                            'Review the generated content below.',
                            style: AppTypography.regular(
                              fontSize: 11,
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(16)),
                ContentSegmentedTabs(
                  left: 'Post Preview',
                  right: 'Text Only',
                  leftSelected: _postPreview,
                  onLeft: () => setState(() => _postPreview = true),
                  onRight: () => setState(() => _postPreview = false),
                ),
                SizedBox(height: ScreenUtils.h(16)),
                if (_postPreview)
                  ContentPostPreviewCard(
                    draft: _draft,
                    onTap: () => context.push(
                      AppRoutes.contentGeneratorSave,
                      extra: _draft,
                    ),
                  )
                else
                  ContentTextOnlyCard(
                    text: _draft.generatedText,
                    onCopy: _copyText,
                  ),
                SizedBox(height: ScreenUtils.h(14)),
                Center(
                  child: GestureDetector(
                    onTap: () => context.push(
                      AppRoutes.contentGeneratorSave,
                      extra: _draft,
                    ),
                    child: Text(
                      'Save or Download',
                      style: AppTypography.semiBold(
                        fontSize: 12,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(24)),
              ],
            ),
          ),
          ContentBottomBar(
            child: ContentPairButtons(
              leftLabel: 'Regenerate',
              rightLabel: 'Edit Again',
              onLeft: _regenerate,
              onRight: _edit,
              rightFilled: _postPreview,
            ),
          ),
        ],
      ),
    );
  }
}
