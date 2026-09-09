import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Responsive sizing utility for iPhone / iPad / iPod.
///
/// Design baseline is iPhone 14 logical size (390 x 844).
/// On iPad, as width grows, [h] scales with screen height so layouts
/// stay proportional across devices.
///
/// Call [ScreenUtils.init] once with a [BuildContext] that has MediaQuery
/// (typically in [MaterialApp.builder]).
///
/// Usage:
/// ```dart
/// width: ScreenUtils.w(24)
/// height: ScreenUtils.h(48)
/// fontSize: ScreenUtils.sp(16)
/// borderRadius: BorderRadius.circular(ScreenUtils.r(12))
/// ```
class ScreenUtils {
  ScreenUtils._();

  /// Design reference — iPhone 14 logical points.
  static const double designWidth = 390;
  static const double designHeight = 844;

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _scaleWidth;
  static late double _scaleHeight;
  static late double _scaleText;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Whether the current device is considered a tablet (iPad-class).
  static bool get isTablet => shortSide >= 600;

  /// Shorter side of the screen (useful for orientation-agnostic checks).
  static double get shortSide => math.min(screenWidth, screenHeight);

  /// Longer side of the screen.
  static double get longSide => math.max(screenWidth, screenHeight);

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    _scaleWidth = screenWidth / designWidth;
    _scaleHeight = screenHeight / designHeight;
    // Text / radius: use the smaller scale so type doesn't blow up on iPad.
    _scaleText = math.min(_scaleWidth, _scaleHeight);
    _initialized = true;
  }

  /// Scales a design width to the current screen width.
  static double w(double width) {
    assert(_initialized, 'Call ScreenUtils.init(context) before using sizes.');
    return width * _scaleWidth;
  }

  /// Scales a design height to the current screen height.
  /// On iPad, taller/wider screens get a proportionally larger height.
  static double h(double height) {
    assert(_initialized, 'Call ScreenUtils.init(context) before using sizes.');
    return height * _scaleHeight;
  }

  /// Scales font sizes using the more conservative of width/height scale.
  static double sp(double fontSize) {
    assert(_initialized, 'Call ScreenUtils.init(context) before using sizes.');
    return fontSize * _scaleText;
  }

  /// Scales corner radii / icon sizes consistently with [sp].
  static double r(double radius) {
    assert(_initialized, 'Call ScreenUtils.init(context) before using sizes.');
    return radius * _scaleText;
  }

  /// Safe area insets from the last [init] call.
  static EdgeInsets get padding => _mediaQueryData.padding;

  static double get topSafe => _mediaQueryData.padding.top;
  static double get bottomSafe => _mediaQueryData.padding.bottom;
}
