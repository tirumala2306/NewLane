import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';
import 'package:newlane/features/content_generator/widgets/content_preview_cards.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class ContentSaveScreen extends StatelessWidget {
  const ContentSaveScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: draft.generatedText));
    if (!context.mounted) {
      return;
    }
    AppSnackBar.showSuccess(
      context,
      title: 'Copied',
      message: 'Caption copied to clipboard.',
    );
  }

  void _info(BuildContext context, String title, String message) {
    AppSnackBar.showInfo(context, title: title, message: message);
  }

  Future<void> _showSaved(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.78),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.r(16)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(20),
              ScreenUtils.h(24),
              ScreenUtils.w(20),
              ScreenUtils.h(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: ScreenUtils.w(56),
                  height: ScreenUtils.w(56),
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: ScreenUtils.sp(28),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(16)),
                Text(
                  'Content Saved!',
                  style: AppTypography.semiBold(fontSize: 18),
                ),
                SizedBox(height: ScreenUtils.h(8)),
                Text(
                  'Your content has been saved to My Content.',
                  textAlign: TextAlign.center,
                  style: AppTypography.regular(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.mutedGrey,
                  ),
                ),
                SizedBox(height: ScreenUtils.h(20)),
                UnifiedButton(
                  label: 'View My Content',
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go(AppRoutes.home);
                  },
                ),
                SizedBox(height: ScreenUtils.h(10)),
                UnifiedButton.outline(
                  label: 'Create New Content',
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go(AppRoutes.contentGenerator);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(context, title: 'SAVE OR DOWNLOAD'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
            child: Text(
              "Choose how you'd like to save your content.",
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 12,
                color: AppColors.mutedGrey,
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
              children: <Widget>[
                const ContentFlyerCard(),
                SizedBox(height: ScreenUtils.h(16)),
                _SaveActionTile(
                  icon: Icons.save_outlined,
                  title: 'Save to my Content',
                  subtitle: 'Save for future use in the app',
                  onTap: () => _showSaved(context),
                ),
                _SaveActionTile(
                  icon: Icons.download_outlined,
                  title: 'Download Image',
                  subtitle: 'Save to your device (PNG)',
                  onTap: () => _info(
                    context,
                    'Download',
                    'Image download will be available soon.',
                  ),
                ),
                _SaveActionTile(
                  icon: Icons.copy_outlined,
                  title: 'Copy Text',
                  subtitle: 'Copy Caption to clipboard',
                  onTap: () => _copy(context),
                ),
                _SaveActionTile(
                  icon: Icons.share_outlined,
                  title: 'Share',
                  subtitle: 'Share directly to other apps',
                  onTap: () => _info(
                    context,
                    'Share',
                    'Sharing to other apps will be available soon.',
                  ),
                ),
                SizedBox(height: ScreenUtils.h(12)),
              ],
            ),
          ),
          ContentBottomBar(
            child: UnifiedButton(
              label: 'Done',
              onPressed: () => _showSaved(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveActionTile extends StatelessWidget {
  const _SaveActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.h(8)),
      child: Material(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.w(14),
              vertical: ScreenUtils.h(12),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: AppColors.primaryButtonBg,
                  size: ScreenUtils.sp(22),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTypography.semiBold(fontSize: 13),
                      ),
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        subtitle,
                        style: AppTypography.regular(
                          fontSize: 11,
                          color: AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryButtonBg,
                  size: ScreenUtils.sp(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
