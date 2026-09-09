import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

enum _UnifiedButtonVariant { filled, outline }

/// App-wide primary action button.
class UnifiedButton extends StatelessWidget {
  const UnifiedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.width,
    this.height,
    this.isExpanded = true,
    this.isLoading = false,
  }) : _variant = _UnifiedButtonVariant.filled;

  const UnifiedButton.outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.width,
    this.height,
    this.isExpanded = true,
    this.isLoading = false,
  }) : _variant = _UnifiedButtonVariant.outline;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double? height;
  final bool isExpanded;
  final bool isLoading;
  final _UnifiedButtonVariant _variant;

  bool get _isOutline => _variant == _UnifiedButtonVariant.outline;

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = height ?? ScreenUtils.h(48);
    final double radius = ScreenUtils.r(10);
    final bool enabled = onPressed != null && !isLoading;

    final Color foreground = _isOutline
        ? AppColors.primaryButtonBg
        : AppColors.black;
    final Color background = _isOutline
        ? Colors.transparent
        : AppColors.primaryButtonBg;
    final BorderSide border = _isOutline
        ? const BorderSide(color: AppColors.primaryButtonBg, width: 1.5)
        : BorderSide.none;

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          IconTheme(
            data: IconThemeData(color: foreground, size: ScreenUtils.sp(18)),
            child: icon!,
          ),
          SizedBox(width: ScreenUtils.w(8)),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.semiBold(fontSize: 16, color: foreground),
          ),
        ),
      ],
    );

    final Widget button = Material(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(radius),
        child: Opacity(
          opacity: enabled || isLoading ? 1 : 0.5,
          child: Container(
            width: width,
            height: buttonHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.fromBorderSide(border),
            ),
            child: isLoading
                ? SizedBox(
                    width: ScreenUtils.sp(22),
                    height: ScreenUtils.sp(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                : content,
          ),
        ),
      ),
    );

    if (isExpanded && width == null) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
