import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';

class ContentGeneratingScreen extends StatefulWidget {
  const ContentGeneratingScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  State<ContentGeneratingScreen> createState() =>
      _ContentGeneratingScreenState();
}

class _ContentGeneratingScreenState extends State<ContentGeneratingScreen> {
  int _completed = 0;

  static const List<String> _steps = <String>[
    'Analyzing your input',
    'Generating content options',
    'Preparing preview',
  ];

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 1; i <= _steps.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) {
        return;
      }
      setState(() => _completed = i);
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) {
      return;
    }

    context.pushReplacement(
      AppRoutes.contentGeneratorPreview,
      extra: widget.draft.copyWith(
        generatedText: ContentGeneratorMock.buildGeneratedText(widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(context, title: 'GENERATING CONTENT'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(24)),
        child: Column(
          children: <Widget>[
            const Spacer(flex: 2),
            Container(
              width: ScreenUtils.w(88),
              height: ScreenUtils.w(88),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryButtonBg,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.description_outlined,
                size: ScreenUtils.sp(36),
                color: AppColors.primaryButtonBg,
              ),
            ),
            SizedBox(height: ScreenUtils.h(22)),
            Text(
              'Creating your content...',
              textAlign: TextAlign.center,
              style: AppTypography.semiBold(fontSize: 18),
            ),
            SizedBox(height: ScreenUtils.h(8)),
            Text(
              'This may take a few seconds. Our AI is crafting the perfect content for you.',
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 12,
                height: 1.4,
                color: AppColors.mutedGrey,
              ),
            ),
            SizedBox(height: ScreenUtils.h(28)),
            ...List<Widget>.generate(_steps.length, (int index) {
              final bool done = _completed > index;
              return Padding(
                padding: EdgeInsets.only(bottom: ScreenUtils.h(12)),
                child: Row(
                  children: <Widget>[
                    Icon(
                      done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: ScreenUtils.sp(18),
                      color: done
                          ? AppColors.primaryButtonBg
                          : AppColors.white.withValues(alpha: 0.25),
                    ),
                    SizedBox(width: ScreenUtils.w(10)),
                    Text(
                      _steps[index],
                      style: AppTypography.regular(
                        fontSize: 13,
                        color: done
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Spacer(flex: 3),
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
                    child: Text(
                      'Great content creates opportunities.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: AppTypography.regular(
                        fontSize: 11,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.h(28)),
          ],
        ),
      ),
    );
  }
}
