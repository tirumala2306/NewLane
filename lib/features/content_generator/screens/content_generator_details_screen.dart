import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_stepper.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class ContentGeneratorDetailsScreen extends StatefulWidget {
  const ContentGeneratorDetailsScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  State<ContentGeneratorDetailsScreen> createState() =>
      _ContentGeneratorDetailsScreenState();
}

class _ContentGeneratorDetailsScreenState
    extends State<ContentGeneratorDetailsScreen> {
  late final TextEditingController _topicController;
  late final TextEditingController _detailsController;
  late final TextEditingController _notesController;
  late String _tone;
  late String _platform;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.draft.topic);
    _detailsController = TextEditingController(text: widget.draft.keyDetails);
    _notesController = TextEditingController(text: widget.draft.notes);
    _tone = widget.draft.tone;
    _platform = widget.draft.platform;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _detailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  ContentGeneratorDraft get _currentDraft => widget.draft.copyWith(
        topic: _topicController.text,
        keyDetails: _detailsController.text,
        notes: _notesController.text,
        tone: _tone,
        platform: _platform,
      );

  void _generate() {
    if (_topicController.text.trim().isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'Topic required',
        message: 'Add a topic or property title to generate content.',
      );
      return;
    }

    context.push(
      AppRoutes.contentGeneratorGenerating,
      extra: _currentDraft,
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

  Future<void> _pickPlatform() async {
    final String? selected = await showContentOptionsSheet(
      context: context,
      title: 'Platform',
      options: ContentGeneratorMock.platforms,
      selected: _platform,
    );
    if (selected != null) {
      setState(() => _platform = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ContentGeneratorType type = widget.draft.type;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(context, title: 'CONTENT GENERATOR'),
      body: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtils.h(8)),
          const ContentGeneratorStepper(currentStep: 2),
          SizedBox(height: ScreenUtils.h(18)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
              children: <Widget>[
                ContentTypeHeader(type: type),
                SizedBox(height: ScreenUtils.h(6)),
                Text(
                  'Enter the details below to generate your content.',
                  style: AppTypography.regular(
                    fontSize: 11,
                    color: AppColors.mutedGrey,
                  ),
                ),
                SizedBox(height: ScreenUtils.h(18)),
                const ContentFieldLabel('Topic / Property Title', required: true),
                SizedBox(height: ScreenUtils.h(8)),
                CustomTextField(
                  controller: _topicController,
                  isExpanded: true,
                  hintText: 'e.g. Modern Family Home in Brickell',
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Key Details'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentTextArea(
                  controller: _detailsController,
                  hintText:
                      'Add key points, features, or message you want to include...',
                  maxLength: 500,
                  minHeight: 110,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Tone'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentDropdownField(value: _tone, onTap: _pickTone),
                if (type.showsPlatform) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(16)),
                  const ContentFieldLabel('Platform'),
                  SizedBox(height: ScreenUtils.h(8)),
                  ContentDropdownField(value: _platform, onTap: _pickPlatform),
                ],
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Additional Notes (Optional)'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentTextArea(
                  controller: _notesController,
                  hintText: 'Any specific request or style...',
                  maxLength: 200,
                  minHeight: 84,
                ),
                SizedBox(height: ScreenUtils.h(24)),
              ],
            ),
          ),
          ContentBottomBar(
            child: UnifiedButton(
              label: 'Generate Content',
              onPressed: _generate,
            ),
          ),
        ],
      ),
    );
  }
}
