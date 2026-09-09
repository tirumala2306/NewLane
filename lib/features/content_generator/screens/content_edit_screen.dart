import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';

class ContentEditScreen extends StatefulWidget {
  const ContentEditScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  State<ContentEditScreen> createState() => _ContentEditScreenState();
}

class _ContentEditScreenState extends State<ContentEditScreen> {
  late final TextEditingController _textController;
  late String _tone;
  bool _socialPostTab = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.draft.generatedText);
    _tone = widget.draft.tone;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _apply() {
    context.pop(
      ContentEditResult(
        draft: widget.draft.copyWith(
          generatedText: _textController.text,
          tone: _tone,
        ),
      ),
    );
  }

  void _regenerate() {
    context.pop(
      ContentEditResult(
        draft: widget.draft.copyWith(
          generatedText: _textController.text,
          tone: _tone,
        ),
        regenerate: true,
      ),
    );
  }

  Future<void> _pickTone() async {
    final String? selected = await showContentOptionsSheet(
      context: context,
      title: 'Tone',
      options: ContentGeneratorMock.tones,
      selected: _tone,
    );
    if (selected != null) {
      setState(() => _tone = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options = ContentGeneratorMock.captionOptions(
      widget.draft,
    );

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(context, title: 'EDIT CONTENT'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(32)),
            child: Text(
              'make changes to the content below or regenerate for a new version.',
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 11,
                height: 1.3,
                color: AppColors.mutedGrey,
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
            child: ContentSegmentedTabs(
              left: 'Social Post Text',
              right: 'Caption Options',
              leftSelected: _socialPostTab,
              onLeft: () => setState(() => _socialPostTab = true),
              onRight: () => setState(() => _socialPostTab = false),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
              children: <Widget>[
                if (_socialPostTab)
                  ContentTextArea(
                    controller: _textController,
                    hintText: 'Edit your post text...',
                    maxLength: 500,
                    minHeight: 220,
                  )
                else
                  ...options.map(
                    (String option) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
                      child: _CaptionOptionTile(
                        text: option,
                        selected: _textController.text == option,
                        onTap: () {
                          setState(() => _textController.text = option);
                        },
                      ),
                    ),
                  ),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Tone'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentDropdownField(
                  value: _tone,
                  onTap: _pickTone,
                  borderColor: AppColors.primaryButtonBg,
                  leading: Icon(
                    Icons.mail_outline,
                    size: ScreenUtils.sp(18),
                    color: AppColors.primaryButtonBg,
                  ),
                ),
                SizedBox(height: ScreenUtils.h(24)),
              ],
            ),
          ),
          ContentBottomBar(
            child: ContentPairButtons(
              leftLabel: 'Regenerate',
              rightLabel: 'Apply Changes',
              onLeft: _regenerate,
              onRight: _apply,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionOptionTile extends StatelessWidget {
  const _CaptionOptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0E0E0E),
      borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenUtils.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
            border: Border.all(
              color: selected
                  ? AppColors.primaryButtonBg
                  : AppColors.glassBorder,
            ),
          ),
          child: Text(
            text,
            style: AppTypography.regular(fontSize: 12, height: 1.45),
          ),
        ),
      ),
    );
  }
}
