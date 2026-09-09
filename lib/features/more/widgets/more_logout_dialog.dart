import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Luxury confirm dialog: gold chrome, red confirm for destructive logout.
class MoreLogoutDialog extends StatelessWidget {
  const MoreLogoutDialog({super.key});

  static const Color _logoutRed = Color(0xFFFF383C);

  /// Returns `true` when the user confirms logout.
  static Future<bool> confirm(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.72),
      builder: (_) => const MoreLogoutDialog(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
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
                Icons.logout,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(28),
              ),
            ),
            SizedBox(height: ScreenUtils.h(20)),
            Text(
              'Logout',
              style: AppTypography.semiBold(fontSize: 20),
            ),
            SizedBox(height: ScreenUtils.h(8)),
            Container(
              width: ScreenUtils.w(40),
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primaryButtonBg,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            SizedBox(height: ScreenUtils.h(16)),
            Text(
              'Are you sure you want to logout from your account?',
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 14,
                height: 1.4,
                color: AppColors.white.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: ScreenUtils.h(28)),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DialogButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                    outlined: true,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Expanded(
                  child: _DialogButton(
                    label: 'Logout',
                    onPressed: () => Navigator.of(context).pop(true),
                    outlined: false,
                    color: _logoutRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.outlined,
    required this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(10));

    return Material(
      color: outlined ? Colors.transparent : color,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          height: ScreenUtils.h(46),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Text(
            label,
            style: AppTypography.semiBold(
              fontSize: 15,
              color: outlined ? color : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
