import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class TrainingOnboardingBanner extends StatelessWidget {
  const TrainingOnboardingBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    super.key,
    this.onWatchNow,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onWatchNow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(8));

    return Container(
      width: double.infinity,
      height: ScreenUtils.h(168),
      decoration: BoxDecoration(
        color: const Color(0xFF070707),
        borderRadius: radius,
        border: Border.all(color: const Color(0x0DBD9037)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                return const ColoredBox(color: Color(0xFF1A1A1A));
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color(0xCC000000),
                    Color(0x66000000),
                    Color(0x33000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ScreenUtils.w(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTypography.semiBold(fontSize: 16, height: 1.2),
                  ),
                  SizedBox(height: ScreenUtils.h(8)),
                  Text(
                    subtitle,
                    style: AppTypography.regular(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: onWatchNow,
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      size: ScreenUtils.sp(18),
                      color: AppColors.primaryButtonBg,
                    ),
                    label: Text(
                      'Watch Now',
                      style: AppTypography.semiBold(
                        fontSize: 12,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryButtonBg,
                      side: const BorderSide(color: AppColors.primaryButtonBg),
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.w(14),
                        vertical: ScreenUtils.h(8),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
