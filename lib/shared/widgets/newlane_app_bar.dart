import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Shared top app bar used across home and inner screens.
///
/// Supports:
/// - [prefixIcon] / [onPrefixPressed] or custom [prefix]
/// - [suffixIcon] / [onSuffixPressed] or custom [suffix]
/// - Center [title] + optional [description], **or** a custom [center] widget
///   (e.g. logo image). [description] still shows under [center] when both
///   are provided.
///
/// ```dart
/// // Home — logo + tagline
/// NewLaneAppBar(
///   prefixIcon: Icons.menu,
///   onPrefixPressed: openDrawer,
///   center: AppSvg(AssetConstants.newLaneAppLogo, height: 44),
///   description: 'ELEVATE. CONNECT. SUCCEED.',
///   suffixIcon: Icons.notifications_none_outlined,
///   onSuffixPressed: openNotifications,
/// )
///
/// // Inner — title + description
/// NewLaneAppBar(
///   prefixIcon: Icons.arrow_back_ios_new,
///   onPrefixPressed: () => context.pop(),
///   title: 'AGENT DIRECTORY',
///   description: 'NEWLANE BRICKWELL',
///   suffixIcon: Icons.tune,
///   suffixIconColor: AppColors.primaryButtonBg,
///   onSuffixPressed: openFilters,
/// )
/// ```
class NewLaneAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewLaneAppBar({
    super.key,
    this.prefixIcon,
    this.onPrefixPressed,
    this.prefix,
    this.prefixIconColor,
    this.suffixIcon,
    this.onSuffixPressed,
    this.suffixIconColor,
    this.suffix,
    this.title,
    this.titleFontSize = 14,
    this.description,
    this.descriptionFontSize = 10,
    this.center,
    this.backgroundColor = AppColors.black,
    this.height,
  });

  /// Leading Material icon. Ignored when [prefix] is set.
  final IconData? prefixIcon;
  final VoidCallback? onPrefixPressed;
  final Color? prefixIconColor;

  /// Custom leading widget (overrides [prefixIcon]).
  final Widget? prefix;

  /// Trailing Material icon. Ignored when [suffix] is set.
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final Color? suffixIconColor;

  /// Custom trailing widget (overrides [suffixIcon]).
  final Widget? suffix;

  /// Center title (white). Ignored when [center] is set.
  final String? title;
  final double titleFontSize;

  /// Optional gold subtitle under [title] or [center].
  final String? description;
  final double descriptionFontSize;

  /// Custom center content (logo / image). Takes priority over [title].
  /// When set with [description], the description is shown below this widget.
  final Widget? center;

  final Color backgroundColor;

  /// Toolbar height excluding status bar. Defaults to ~56 design px.
  final double? height;

  double get _toolbarHeight {
    if (height != null) {
      return height!;
    }
    return ScreenUtils.isInitialized ? ScreenUtils.h(56) : 56;
  }

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final double iconSize = ScreenUtils.isInitialized ? ScreenUtils.sp(22) : 22;

    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: _toolbarHeight,
      leadingWidth: ScreenUtils.isInitialized ? ScreenUtils.w(56) : 56,
      leading: _buildPrefix(iconSize),
      title: _buildCenter(),
      titleSpacing: 0,
      actions: <Widget>[
        if (suffix != null || suffixIcon != null)
          Padding(
            padding: EdgeInsets.only(
              right: ScreenUtils.isInitialized ? ScreenUtils.w(8) : 8,
            ),
            child: _buildSuffix(iconSize),
          ),
      ],
    );
  }

  Widget? _buildPrefix(double iconSize) {
    if (prefix != null) {
      return prefix;
    }
    if (prefixIcon == null) {
      return null;
    }
    return IconButton(
      onPressed: onPrefixPressed,
      icon: Icon(
        prefixIcon,
        size: iconSize,
        color: prefixIconColor ?? AppColors.primaryButtonBg,
      ),
    );
  }

  Widget _buildSuffix(double iconSize) {
    if (suffix != null) {
      return suffix!;
    }
    return IconButton(
      onPressed: onSuffixPressed,
      icon: Icon(
        suffixIcon,
        size: iconSize,
        color: suffixIconColor ?? AppColors.primaryButtonBg,
      ),
    );
  }

  Widget? _buildCenter() {
    final Widget? resolvedCenter = center;
    final String? resolvedTitle = title;
    final String? resolvedDescription = description;

    if (resolvedCenter == null &&
        resolvedTitle == null &&
        resolvedDescription == null) {
      return null;
    }

    final Widget? primary = resolvedCenter ??
        (resolvedTitle != null
            ? Text(
                resolvedTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.semiBold(
                  fontSize: titleFontSize,
                  color: AppColors.white,
                ),
              )
            : null);

    if (resolvedDescription == null) {
      return primary;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ?primary,
        if (primary != null)
          SizedBox(height: ScreenUtils.isInitialized ? ScreenUtils.h(2) : 2),
        Text(
          resolvedDescription,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.medium(
            fontSize: descriptionFontSize,
            color: AppColors.primaryButtonBg,
          ),
        ),
      ],
    );
  }
}
