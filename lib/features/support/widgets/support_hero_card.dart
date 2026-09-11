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

  @override
  Widget build(BuildContext context) {
    final double height = ScreenUtils.h(168);
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(10));

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const AppSvg(
              AssetConstants.profileBg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            // Scrim so text stays readable over the skyline.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    AppColors.black.withValues(alpha: 0.82),
                    AppColors.black.withValues(alpha: 0.45),
                    AppColors.black.withValues(alpha: 0.2),
                  ],
                  stops: const <double>[0, 0.55, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(18),
                ScreenUtils.w(16),
                ScreenUtils.h(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'How can we help you?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.semiBold(fontSize: 16, height: 1.2),
                  ),
                  SizedBox(height: ScreenUtils.h(6)),
                  SizedBox(
                    width: ScreenUtils.w(210),
                    child: Text(
                      'Our support team is here to assist you with any questions or issues.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.regular(
                        fontSize: 11,
                        height: 1.35,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _OutlineChatButton(onTap: onChatTap),
                ],
              ),
            ),
          ],
        ),
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
            horizontal: ScreenUtils.w(12),
            vertical: ScreenUtils.h(8),
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
                size: ScreenUtils.sp(14),
                color: AppColors.primaryButtonBg,
              ),
              SizedBox(width: ScreenUtils.w(6)),
              Text(
                'Chat with Support',
                style: AppTypography.semiBold(
                  fontSize: 11,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
