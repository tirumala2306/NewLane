import 'package:flutter/material.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Shared dark card used across More screens.
class MoreCard extends StatelessWidget {
  const MoreCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding,
    this.height,
    this.borderColor,
  });

  static const Color background = Color(0xFF070707);
  static const Color border = Color(0x0DBD9037);

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(8));
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? EdgeInsets.all(ScreenUtils.w(16));

    final Widget content = Container(
      width: double.infinity,
      height: height,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? border),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
