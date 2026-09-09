import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class SupportHeroCard extends StatelessWidget {
  const SupportHeroCard({
    super.key,
    this.onChatTap,
  });

  final VoidCallback? onChatTap;

  static const Color _cardBg = Color(0xFF010204);
  static const Color _cardBorder = Color(0x1ABD9037);

  @override
  Widget build(BuildContext context) {
    final double height = ScreenUtils.h(147);
    final double imageWidth = ScreenUtils.w(238);
    final double corner = ScreenUtils.r(8);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(corner),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Right-side image only.
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: imageWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(corner),
                bottomRight: Radius.circular(corner),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const AppSvg(
                    AssetConstants.profileBg,
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: ScreenUtils.w(48),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[
                            _cardBg,
                            _cardBg.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Left content over dark area.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            // width: ScreenUtils.w(200),
            child: Padding(
              padding: EdgeInsets.only(
                left: ScreenUtils.w(16),
                top: ScreenUtils.h(24),
                bottom: ScreenUtils.h(12 ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'How can we help you?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.semiBold(fontSize: 14, height: 1.2),
                  ),
                  SizedBox(height: ScreenUtils.h(4)),
                  SizedBox(
                    width: ScreenUtils.w(150),
                    child: Text(
                      'Our support team is here to assist you with any questions or issues.',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.regular(
                        fontSize: 10,
                        height: 1.35,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.h(16)),
                  _OutlineChatButton(onTap: onChatTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineChatButton extends StatelessWidget {
  const _OutlineChatButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(10),
            vertical: ScreenUtils.h(6),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.primaryButtonBg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                CupertinoIcons.chat_bubble_text,
                size: ScreenUtils.sp(12),
                color: AppColors.primaryButtonBg,
              ),
              SizedBox(width: ScreenUtils.w(4)),
              Flexible(
                child: Text(
                  'Chat with Support',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.semiBold(
                    fontSize: 10,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
