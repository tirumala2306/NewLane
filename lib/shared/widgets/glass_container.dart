import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

/// Frosted-glass panel with real blur that stays stable while scrolling.
///
/// Uses a screen-aligned blurred copy of [backgroundAsset] instead of
/// [BackdropFilter], which Impeller drops during scroll/overscroll.
class GlassContainer extends StatefulWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.backgroundAsset,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1,
    this.frostColor,
    this.blurSigma = 28,
    this.width,
  });

  final Widget child;

  /// Screen background asset (same as the page bg). Enables real frosted glass.
  final String? backgroundAsset;

  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? frostColor;
  final double blurSigma;
  final double? width;

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  final GlobalKey _key = GlobalKey();
  Offset _globalOffset = Offset.zero;
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? next = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != next) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = next;
      _scrollPosition?.addListener(_onScroll);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOffset());
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => _syncOffset();

  void _syncOffset() {
    final RenderObject? object = _key.currentContext?.findRenderObject();
    if (object is! RenderBox || !object.hasSize || !object.attached) {
      return;
    }
    final Offset next = object.localToGlobal(Offset.zero);
    if (next != _globalOffset) {
      setState(() => _globalOffset = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        widget.borderRadius ?? BorderRadius.circular(ScreenUtils.r(12));
    final Color frost =
        widget.frostColor ?? AppColors.white.withValues(alpha: 0.08);
    final Color stroke =
        widget.borderColor ?? AppColors.white.withValues(alpha: 0.40);
    final Size screen = MediaQuery.sizeOf(context);

    return ClipRRect(
      key: _key,
      borderRadius: radius,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          if (widget.backgroundAsset != null)
            Positioned(
              left: -_globalOffset.dx,
              top: -_globalOffset.dy,
              width: screen.width,
              height: screen.height,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                  tileMode: TileMode.decal,
                ),
                child: AppSvg(
                  widget.backgroundAsset!,
                  fit: BoxFit.cover,
                  width: screen.width,
                  height: screen.height,
                ),
              ),
            ),
          // Frost tint over blur (design glass look).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    frost,
                    AppColors.black.withValues(alpha: 0.35),
                    AppColors.black.withValues(alpha: 0.55),
                  ],
                  stops: const <double>[0, 0.55, 1],
                ),
              ),
            ),
          ),
          Container(
            width: widget.width ?? double.infinity,
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: stroke, width: widget.borderWidth),
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
