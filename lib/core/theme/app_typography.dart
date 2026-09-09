import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// App-wide Montserrat typography.
///
/// Defaults: white color, line-height 100%. Override [color], [fontSize],
/// and/or [height] as needed.
///
/// ```dart
/// AppTypography.regular()
/// AppTypography.regular(color: AppColors.primaryButtonBg, fontSize: 16, height: 1.4)
/// ```
class AppTypography {
  const AppTypography._();

  static const String _fontFamily = 'Montserrat';

  static double _sp(double size) {
    return ScreenUtils.isInitialized ? ScreenUtils.sp(size) : size;
  }

  /// Regular — default 12px / weight 400 / letter-spacing 0% / line-height 100%.
  static TextStyle regular({
    Color color = AppColors.white,
    double fontSize = 12,
    double height = 1.0,
  }) {
    return GoogleFonts.montserrat(
      fontWeight: FontWeight.w400,
      fontSize: _sp(fontSize),
      height: height,
      letterSpacing: 0,
      color: color,
    );
  }

  /// Medium — default 14px / weight 500 / letter-spacing 2% / line-height 100%.
  static TextStyle medium({
    Color color = AppColors.white,
    double fontSize = 14,
    double height = 1.0,
  }) {
    final double size = _sp(fontSize);
    return GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
      fontSize: size,
      height: height,
      letterSpacing: size * 0.02,
      color: color,
    );
  }

  /// SemiBold — default 14px / weight 600 / letter-spacing 0% / line-height 100%.
  static TextStyle semiBold({
    Color color = AppColors.white,
    double fontSize = 14,
    double height = 1.0,
  }) {
    return GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: _sp(fontSize),
      height: height,
      letterSpacing: 0,
      color: color,
    );
  }

  /// Font family name for ThemeData / ThemeExtension use.
  static String get fontFamily => _fontFamily;
}
