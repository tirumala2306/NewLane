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
import 'package:newlane/features/content_generator/widgets/content_preview_cards.dart';
import 'package:newlane/features/feed/domain/usecases/feed_usecases.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class ContentPreviewScreen extends StatefulWidget {
  const ContentPreviewScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  State<ContentPreviewScreen> createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  late ContentGeneratorDraft _draft;
  late TextEditingController _captionController;
  final GlobalKey _previewKey = GlobalKey();

  bool _busy = false;
  bool _editingCaption = false;
  bool _captionDirty = false;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _captionController = TextEditingController(text: _draft.generatedCaption)
      ..addListener(_onCaptionChanged);
  }

  void _onCaptionChanged() {
    final bool dirty =
        _captionController.text.trim() != _draft.generatedCaption.trim();
    if (dirty != _captionDirty) {
      setState(() => _captionDirty = dirty);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _changeFormat(ContentFormat format) async {
    if (_draft.format == format || _busy) return;
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
          _captionController.text = value.caption;
          _captionDirty = false;
          _editingCaption = false;
        });
      },
      err: (_) {
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
          _captionController.text = value.caption;
          _captionDirty = false;
          _editingCaption = false;
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

  void _saveCaption() {
    FocusScope.of(context).unfocus();
    final String text = _captionController.text.trim();
    setState(() {
      _draft = _draft.copyWith(generatedCaption: text);
      _captionDirty = false;
      _editingCaption = false;
    });
    AppSnackBar.showSuccess(
      context,
      title: 'Saved',
      message: 'Caption updated.',
    );
  }

  Future<void> _download() async {
    if (_actionLoading || _busy) return;
    setState(() => _actionLoading = true);
    try {
      // Let the frame paint before capture.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final String? path = await captureTemplatePng(_previewKey);
      if (!mounted) return;
      if (path == null) {
        AppSnackBar.showError(
          context,
          title: 'Download',
          message: 'Could not save the template image.',
        );
        return;
      }
      AppSnackBar.showSuccess(
        context,
        title: 'Downloaded',
        message: 'Saved to $path',
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<bool> _confirmShare() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.72),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(32)),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(24),
              ScreenUtils.h(28),
              ScreenUtils.w(24),
              ScreenUtils.h(24),
            ),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(ScreenUtils.r(16)),
              border: Border.all(
                color: AppColors.primaryButtonBg.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: ScreenUtils.w(64),
                  height: ScreenUtils.w(64),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryButtonBg.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.ios_share,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(28),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(20)),
                Text(
                  'Share to Feed?',
                  style: AppTypography.semiBold(fontSize: 18),
                ),
                SizedBox(height: ScreenUtils.h(8)),
                Container(
                  width: ScreenUtils.w(40),
                  height: 2,
                  color: AppColors.primaryButtonBg,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                Text(
                  'This template will be posted to the Feed for your office to see.',
                  textAlign: TextAlign.center,
                  style: AppTypography.regular(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(24)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: UnifiedButton.outline(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(false),
                        isExpanded: true,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(12)),
                    Expanded(
                      child: UnifiedButton(
                        label: 'Share',
                        onPressed: () => Navigator.of(context).pop(true),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return ok == true;
  }

  Future<void> _shareToFeed() async {
    if (_actionLoading || _busy) return;
    if (_captionDirty) _saveCaption();

    final bool confirmed = await _confirmShare();
    if (!confirmed || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final String? captured = await captureTemplatePng(_previewKey);
      final List<String> media = <String>[
        if (captured != null && captured.isNotEmpty) captured,
        ..._draft.photoPaths,
      ];

      final String caption = _draft.generatedCaption.trim().isEmpty
          ? _draft.propertyAddress
          : _draft.generatedCaption.trim();

      final Result result = await InjectionContainer.instance.createFeedPost(
        CreateFeedPostParams(
          caption: caption,
          postType: 'Listing',
          visibility: 'Office',
          mediaPaths: media.take(1).toList(),
          locationLabel: _draft.propertyAddress,
          price: _draft.price,
        ),
      );
      if (!mounted) return;

      result.when(
        ok: (_) {
          AppSnackBar.showSuccess(
            context,
            title: 'Shared',
            message: 'Template posted to Feed.',
          );
          context.go(AppRoutes.feed);
        },
        err: (failure) {
          AppSnackBar.showError(
            context,
            title: 'Share failed',
            message: failure.message,
          );
        },
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ContentGraphicSpec? spec = _draft.graphicSpec;
    final bool blocked = _busy || _actionLoading;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(
        context,
        title: 'TEMPLATE PREVIEW',
        description: 'Step 2 of 3',
        suffix: TextButton(
          onPressed: blocked || !_captionDirty ? null : _saveCaption,
          child: Text(
            'Save',
            style: AppTypography.semiBold(
              fontSize: 13,
              color: _captionDirty && !blocked
                  ? AppColors.primaryButtonBg
                  : AppColors.mutedGrey,
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
                  onChanged: blocked ? (_) {} : _changeFormat,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'SELECTED TEMPLATE',
                            style: AppTypography.regular(
                              fontSize: 10,
                              color: AppColors.mutedGrey,
                            ).copyWith(letterSpacing: 0.8),
                          ),
                          SizedBox(height: ScreenUtils.h(4)),
                          Text(
                            spec?.template ?? _draft.templateName,
                            style: AppTypography.semiBold(fontSize: 15),
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
                    OutlinedButton.icon(
                      onPressed: blocked ? null : _changeTemplate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryButtonBg,
                        side: const BorderSide(
                          color: AppColors.primaryButtonBg,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtils.w(12),
                          vertical: ScreenUtils.h(8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.r(8),
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.open_in_full,
                        size: ScreenUtils.sp(14),
                      ),
                      label: Text(
                        'Change',
                        style: AppTypography.semiBold(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(14)),
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
                  TemplateGraphicPreview(
                    draft: _draft,
                    repaintKey: _previewKey,
                  ),
                SizedBox(height: ScreenUtils.h(18)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Caption',
                        style: AppTypography.semiBold(fontSize: 13),
                      ),
                    ),
                    if (!_editingCaption)
                      TextButton.icon(
                        onPressed: blocked
                            ? null
                            : () => setState(() => _editingCaption = true),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: ScreenUtils.sp(14),
                          color: AppColors.primaryButtonBg,
                        ),
                        label: Text(
                          'Edit',
                          style: AppTypography.semiBold(
                            fontSize: 12,
                            color: AppColors.primaryButtonBg,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(8)),
                if (_editingCaption)
                  ContentTextArea(
                    controller: _captionController,
                    hintText: 'Write your caption…',
                    maxLength: 1200,
                    minHeight: 120,
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: blocked
                          ? null
                          : () => setState(() => _editingCaption = true),
                      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(ScreenUtils.w(12)),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.r(8),
                          ),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          _draft.generatedCaption.trim().isEmpty
                              ? 'Tap to add a caption…'
                              : _draft.generatedCaption,
                          style: AppTypography.regular(
                            fontSize: 12,
                            height: 1.4,
                            color: _draft.generatedCaption.trim().isEmpty
                                ? AppColors.mutedGrey
                                : AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_editingCaption) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(10)),
                  UnifiedButton(
                    label: 'Save changes',
                    onPressed: blocked ? () {} : _saveCaption,
                    isExpanded: true,
                  ),
                ],
              ],
            ),
          ),
          ContentBottomBar(
            child: ContentPairButtons(
              leftLabel: 'Download',
              rightLabel: 'Share Template',
              leftIcon: _actionLoading
                  ? SizedBox(
                      width: ScreenUtils.sp(16),
                      height: ScreenUtils.sp(16),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryButtonBg,
                      ),
                    )
                  : const Icon(Icons.download_outlined),
              rightIcon: const Icon(Icons.ios_share),
              onLeft: blocked ? () {} : _download,
              onRight: blocked ? () {} : _shareToFeed,
            ),
          ),
        ],
      ),
    );
  }
}
