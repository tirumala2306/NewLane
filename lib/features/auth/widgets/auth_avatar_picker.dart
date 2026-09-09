import 'dart:io';

import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Circular avatar with gold camera badge. Shows local preview when [imageFile] is set.
class AuthAvatarPicker extends StatelessWidget {
  const AuthAvatarPicker({
    super.key,
    this.onTap,
    this.size,
    this.imageFile,
    this.networkUrl,
  });

  final VoidCallback? onTap;
  final double? size;
  final File? imageFile;
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    final double resolved = size ?? ScreenUtils.w(120);

    return Center(
      child: SizedBox(
        width: resolved,
        height: resolved,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: resolved,
              height: resolved,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFF535353),
                  width: ScreenUtils.r(4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImage(resolved),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: ScreenUtils.w(34),
                  height: ScreenUtils.w(34),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButtonBg,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: ScreenUtils.sp(20),
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double size) {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    final String? url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return _placeholder();
        },
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Icon(
      Icons.person,
      size: ScreenUtils.sp(80),
      color: const Color(0xFF535353),
    );
  }
}
