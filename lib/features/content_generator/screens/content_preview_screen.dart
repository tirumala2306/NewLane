import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
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
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  Future<void> _changeFormat(ContentFormat format) async {
    if (_draft.format == format) return;
    setState(() {
      _draft = _draft.copyWith(format: format);
      _busy = true;
    });

    final Result<ContentGenerateResult> result =
        await InjectionContainer.instance.generateContent(_draft);
    if (!mounted) return;

    result.when(
      ok: (ContentGenerateResult value) {
        setState(() {
          _busy = false;
          _draft = _draft.copyWith(
            generatedCaption: value.caption,
            graphicSpec: value.graphicSpec.copyWith(format: format),
            templateName: value.graphicSpec.template,
            format: format,
          );
        });
      },
      err: (_) {
        // Keep local aspect-ratio change even if regenerate fails.
        setState(() {
          _busy = false;
          final ContentGraphicSpec? spec = _draft.graphicSpec;
          if (spec != null) {
            _draft = _draft.copyWith(
              graphicSpec: spec.copyWith(format: format),
            );
          }
        });
      },
    );
  }

  Future<void> _changeTemplate() async {
    final Result<List<ContentTemplate>> result =
        await InjectionContainer.instance.fetchContentTemplates();
    if (!mounted) return;

    List<ContentTemplate> templates = const <ContentTemplate>[];
    result.when(
      ok: (List<ContentTemplate> list) => templates = list,
      err: (failure) {
        AppSnackBar.showError(
          context,
          title: 'Templates',
          message: failure.message,
        );
      },
    );
    if (templates.isEmpty || !mounted) return;

    final ContentTemplate? selected =
        await showModalBottomSheet<ContentTemplate>(
          context: context,
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtils.r(16)),
            ),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(ScreenUtils.w(16)),
                    child: Text(
                      'Choose Template',
                      style: AppTypography.semiBold(fontSize: 14),
                    ),
                  ),
                  ...templates.map(
                    (ContentTemplate t) => ListTile(
                      title: Text(
                        t.name,
                        style: AppTypography.medium(fontSize: 14),
                      ),
                      subtitle: Text(
                        t.category,
                        style: AppTypography.regular(
                          fontSize: 11,
                          color: AppColors.mutedGrey,
                        ),
                      ),
                      trailing: _draft.templateName == t.name
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primaryButtonBg,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, t),
                    ),
                  ),
                ],
              ),
            );
          },
        );
    if (selected == null || !mounted) return;

    setState(() {
      _busy = true;
      _draft = _draft.copyWith(templateName: selected.name);
    });

    final Result<ContentGenerateResult> gen =
        await InjectionContainer.instance.generateContent(_draft);
    if (!mounted) return;
    gen.when(
      ok: (ContentGenerateResult value) {
        setState(() {
          _busy = false;
          _draft = _draft.copyWith(
            generatedCaption: value.caption,
            graphicSpec: value.graphicSpec,
            templateName: value.graphicSpec.template,
          );
        });
      },
      err: (failure) {
        setState(() => _busy = false);
        AppSnackBar.showError(
          context,
          title: 'Generate failed',
          message: failure.message,
        );
      },
    );
  }

  Future<void> _copyCaption() async {
    final String text = _draft.generatedCaption.trim();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppSnackBar.showSuccess(
      context,
      title: 'Copied',
      message: 'Caption copied to clipboard.',
    );
  }

  Future<void> _share() async {
    final String text = _draft.generatedCaption.trim().isEmpty
        ? _draft.propertyAddress
        : _draft.generatedCaption.trim();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppSnackBar.showSuccess(
      context,
      title: 'Ready to share',
      message: 'Caption copied — paste it in your social app.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ContentGraphicSpec? spec = _draft.graphicSpec;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(
        context,
        title: 'TEMPLATE PREVIEW',
        description: 'Step 2 of 3',
        suffix: TextButton(
          onPressed: _copyCaption,
          child: Text(
            'Next',
            style: AppTypography.semiBold(
              fontSize: 13,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(8),
                ScreenUtils.w(16),
                ScreenUtils.h(16),
              ),
              children: <Widget>[
                ContentFormatSelector(
                  selected: _draft.format,
                  onChanged: _busy ? (_) {} : _changeFormat,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            spec?.template ?? _draft.templateName,
                            style: AppTypography.semiBold(fontSize: 14),
                          ),
                          SizedBox(height: ScreenUtils.h(2)),
                          Text(
                            spec?.category ?? 'Real Estate Listing',
                            style: AppTypography.regular(
                              fontSize: 11,
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _busy ? null : _changeTemplate,
                      icon: Icon(
                        Icons.swap_horiz,
                        size: ScreenUtils.sp(16),
                        color: AppColors.primaryButtonBg,
                      ),
                      label: Text(
                        'Change',
                        style: AppTypography.semiBold(
                          fontSize: 12,
                          color: AppColors.primaryButtonBg,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(12)),
                if (_busy)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(40)),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  )
                else
                  TemplateGraphicPreview(draft: _draft),
                if (_draft.generatedCaption.trim().isNotEmpty) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(18)),
                  Text(
                    'Caption',
                    style: AppTypography.semiBold(fontSize: 13),
                  ),
                  SizedBox(height: ScreenUtils.h(8)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ScreenUtils.w(12)),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      _draft.generatedCaption,
                      style: AppTypography.regular(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ContentBottomBar(
            child: ContentPairButtons(
              leftLabel: 'Download',
              rightLabel: 'Share Template',
              leftIcon: const Icon(Icons.download_outlined),
              rightIcon: const Icon(Icons.ios_share),
              onLeft: _copyCaption,
              onRight: _share,
            ),
          ),
        ],
      ),
    );
  }
}
