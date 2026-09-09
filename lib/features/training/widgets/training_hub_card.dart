import 'package:flutter/material.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class TrainingHubCard extends StatelessWidget {
  const TrainingHubCard({
    required this.child,
    super.key,
    this.onTap,
    this.height,
  });

  static const Color background = Color(0xFF070707);
  static const Color border = Color(0x0DBD9037);

  final Widget child;
  final VoidCallback? onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(8));
    final double resolvedHeight = height ?? ScreenUtils.h(63);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          height: resolvedHeight,
          padding: EdgeInsets.all(ScreenUtils.w(16)),
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}
