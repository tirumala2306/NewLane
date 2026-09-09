import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// Success dialog after the request-access form is submitted.
class RequestSubmittedDialog extends StatelessWidget {
  const RequestSubmittedDialog({super.key, this.onDone});

  final VoidCallback? onDone;

  static Future<void> show(BuildContext context, {VoidCallback? onDone}) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Request Submitted',
      barrierColor: AppColors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return RequestSubmittedDialog(onDone: onDone);
      },
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(28)),
          child: AuthGlassCard(
            borderRadius: BorderRadius.circular(ScreenUtils.r(16)),
            borderColor: AppColors.white.withValues(alpha: 0.4),
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(24),
              ScreenUtils.h(32),
              ScreenUtils.w(24),
              ScreenUtils.h(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppSvg(
                  AssetConstants.newLaneAppLogo,
                  height: ScreenUtils.h(100),
                ),
                SizedBox(height: ScreenUtils.h(28)),
                const RequestSuccessBadge(),
                SizedBox(height: ScreenUtils.h(28)),
                Text(
                  'Request Submitted!',
                  textAlign: TextAlign.center,
                  style: AppTypography.semiBold(fontSize: 24),
                ),
                SizedBox(height: ScreenUtils.h(16)),
                Text(
                  "Your request has been submitted. We'll review your information and contact you shortly.",
                  textAlign: TextAlign.center,
                  style: AppTypography.regular(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.white.withValues(alpha: 0.80),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(50)),
                UnifiedButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDone?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold-ringed check icon in the success dialog.
class RequestSuccessBadge extends StatelessWidget {
  const RequestSuccessBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(100),
      height: ScreenUtils.w(100),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryButtonBg, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.w(24)),
        child: AppSvg(
          AssetConstants.circleCheckIcon,
          width: ScreenUtils.w(40),
          height: ScreenUtils.h(40),
        ),
      ),
    );
  }
}
