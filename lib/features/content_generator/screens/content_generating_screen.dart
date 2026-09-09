import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class ContentGeneratingScreen extends StatefulWidget {
  const ContentGeneratingScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  State<ContentGeneratingScreen> createState() =>
      _ContentGeneratingScreenState();
}

class _ContentGeneratingScreenState extends State<ContentGeneratingScreen> {
  int _completed = 0;
  bool _failed = false;
  String _error = '';

  static const List<String> _steps = <String>[
    'Analyzing your listing',
    'Generating caption & graphic',
    'Preparing template preview',
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _completed = 0;
      _failed = false;
      _error = '';
    });

    for (int i = 1; i <= 2; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _completed = i);
    }

    final Result<ContentGenerateResult> result =
        await InjectionContainer.instance.generateContent(widget.draft);

    if (!mounted) return;

    result.when(
      ok: (ContentGenerateResult value) async {
        setState(() => _completed = 3);
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        context.pushReplacement(
          AppRoutes.contentGeneratorPreview,
          extra: widget.draft.copyWith(
            generatedCaption: value.caption,
            graphicSpec: value.graphicSpec,
            templateName: value.graphicSpec.template,
            format: value.graphicSpec.format,
          ),
        );
      },
      err: (failure) {
        setState(() {
          _failed = true;
          _error = failure.message;
        });
        AppSnackBar.showError(
          context,
          title: 'Generate failed',
          message: failure.message,
        );
      },
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
                Icons.auto_awesome,
                size: ScreenUtils.sp(36),
                color: AppColors.primaryButtonBg,
              ),
            ),
            SizedBox(height: ScreenUtils.h(22)),
            Text(
              _failed ? 'Could not generate content' : 'Creating your content...',
              textAlign: TextAlign.center,
              style: AppTypography.semiBold(fontSize: 18),
            ),
            SizedBox(height: ScreenUtils.h(8)),
            Text(
              _failed
                  ? _error
                  : 'This may take a few seconds. Our AI is crafting the perfect content for you.',
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 12,
                height: 1.4,
                color: AppColors.mutedGrey,
              ),
            ),
            SizedBox(height: ScreenUtils.h(28)),
            if (!_failed)
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
            if (_failed) ...<Widget>[
              UnifiedButton(label: 'Try Again', onPressed: _run),
              SizedBox(height: ScreenUtils.h(10)),
              UnifiedButton.outline(
                label: 'Go Back',
                onPressed: () => context.pop(),
              ),
            ],
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
