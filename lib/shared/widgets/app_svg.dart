import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable asset image widget (SVG + PNG/JPG).
///
/// Usage:
/// ```dart
/// AppSvg(AssetConstants.splashImage)
/// AppSvg(AssetConstants.newLaneAppLogo, width: 120, height: 40)
/// ```
class AppSvg extends StatelessWidget {
  const AppSvg(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.semanticsLabel,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final AlignmentGeometry alignment;
  final bool matchTextDirection;
  final String? semanticsLabel;

  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        matchTextDirection: matchTextDirection,
        semanticsLabel: semanticsLabel,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      matchTextDirection: matchTextDirection,
      semanticLabel: semanticsLabel,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
    );
  }
}
