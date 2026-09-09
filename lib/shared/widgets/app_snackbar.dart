import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

enum AppSnackBarType { success, error, info }

/// Floating gold / red / blue snackbars.
///
/// Use success only when the user stays on the same screen.
/// Dedicated success screens (Request Submitted, Request Pending) do not need it.
class AppSnackBar {
  const AppSnackBar._();

  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _show(
      context,
      type: AppSnackBarType.success,
      title: title,
      message: message,
    );
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _show(
      context,
      type: AppSnackBarType.error,
      title: title,
      message: message,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _show(
      context,
      type: AppSnackBarType.info,
      title: title,
      message: message,
    );
  }

  static void _show(
    BuildContext context, {
    required AppSnackBarType type,
    required String title,
    required String message,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 4),
          padding: EdgeInsets.zero,
          margin: EdgeInsets.fromLTRB(
            ScreenUtils.w(16),
            0,
            ScreenUtils.w(16),
            ScreenUtils.h(16),
          ),
          content: AppSnackBarBanner(
            type: type,
            title: title,
            message: message,
            onClose: messenger.hideCurrentSnackBar,
          ),
        ),
      );
  }
}

/// Visual card used inside [AppSnackBar].
class AppSnackBarBanner extends StatelessWidget {
  const AppSnackBarBanner({
    required this.type,
    required this.title,
    required this.message,
    super.key,
    this.onClose,
  });

  final AppSnackBarType type;
  final String title;
  final String message;
  final VoidCallback? onClose;

  Color get _accent {
    return switch (type) {
      AppSnackBarType.success => AppColors.primaryButtonBg,
      AppSnackBarType.error => AppColors.snackError,
      AppSnackBarType.info => AppColors.snackInfo,
    };
  }

  IconData get _icon {
    return switch (type) {
      AppSnackBarType.success => Icons.check,
      AppSnackBarType.error => Icons.priority_high,
      AppSnackBarType.info => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ScreenUtils.w(12),
        ScreenUtils.h(12),
        ScreenUtils.w(8),
        ScreenUtils.h(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(ScreenUtils.r(12)),
        border: Border.all(color: _accent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: ScreenUtils.w(32),
            height: ScreenUtils.w(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accent),
            ),
            child: Icon(_icon, size: ScreenUtils.sp(16), color: _accent),
          ),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: AppTypography.semiBold(fontSize: 13)),
                SizedBox(height: ScreenUtils.h(4)),
                Text(
                  message,
                  style: AppTypography.regular(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.close,
              size: ScreenUtils.sp(16),
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
