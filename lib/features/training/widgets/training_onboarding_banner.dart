import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

/// Onboarding / featured banner — left copy, right [profileBg] skyline.
class TrainingOnboardingBanner extends StatelessWidget {
  const TrainingOnboardingBanner({
    required this.title,
    required this.subtitle,
    super.key,
    this.onWatchNow,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onWatchNow;

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
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
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
                  if (imageUrl != null && imageUrl!.trim().isNotEmpty)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const AppSvg(
                        AssetConstants.profileBg,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const AppSvg(
                      AssetConstants.profileBg,
                      fit: BoxFit.cover,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: ScreenUtils.w(56),
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
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(20),
                ScreenUtils.w(12),
                ScreenUtils.h(12),
              ),
              child: SizedBox(
                width: ScreenUtils.w(150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.semiBold(fontSize: 14, height: 1.2),
                    ),
                    SizedBox(height: ScreenUtils.h(6)),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.regular(
                        fontSize: 10,
                        height: 1.35,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const Spacer(),
                    if (onWatchNow != null) _WatchNowButton(onTap: onWatchNow),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchNowButton extends StatelessWidget {
  const _WatchNowButton({this.onTap});

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
                Icons.play_arrow_rounded,
                size: ScreenUtils.sp(14),
                color: AppColors.primaryButtonBg,
              ),
              SizedBox(width: ScreenUtils.w(4)),
              Text(
                'Watch Now',
                style: AppTypography.semiBold(
                  fontSize: 10,
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
