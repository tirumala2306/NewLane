import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Circular profile avatar with primary border and optional online dot.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.url,
    this.size,
    this.showOnline = false,
    this.isOnline = false,
  });

  final String? url;
  final double? size;
  final bool showOnline;
  final bool isOnline;

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = size ?? ScreenUtils.w(60);
    const double borderWidth = 1;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: resolvedSize,
            height: resolvedSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardSurface,
              border: Border.all(
                color: AppColors.primaryButtonBg,
                width: borderWidth,
              ),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: resolvedSize - (borderWidth * 1),
              height: resolvedSize - (borderWidth * 1),
              child: ClipOval(
                child: _hasUrl
                    ? Image.network(
                        url!,
                        fit: BoxFit.cover,
                        width: resolvedSize,
                        height: resolvedSize,
                        errorBuilder: (context, error, stackTrace) =>
                            _fallback(resolvedSize),
                      )
                    : _fallback(resolvedSize),
              ),
            ),
          ),
          if (showOnline)
            Positioned(
              right: 8,
              bottom: 2,
              child: Container(
                width: ScreenUtils.w(14),
                height: ScreenUtils.w(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? const Color(0xFF22AF4D)
                      : AppColors.mutedGrey,
                  border: Border.all(color: AppColors.black, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback(double resolvedSize) {
    return ColoredBox(
      color: AppColors.cardSurface,
      child: Center(
        child: Icon(
          Icons.person,
          size: resolvedSize * 0.5,
          color: AppColors.primaryButtonBg,
        ),
      ),
    );
  }
}
