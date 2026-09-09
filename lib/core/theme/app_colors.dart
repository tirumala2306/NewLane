import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  /// Brand gold — primary CTA / accents (#BD9037).
  static const Color primaryButtonBg = Color(0xFFBD9037);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Glass / input border — #EFEFEF at ~20% opacity.
  static const Color glassBorder = Color(0x33EFEFEF);

  /// Dark elevated surfaces on black (cards, tiles).
  static const Color cardSurface = Color(0xFF111113);

  /// Secondary / meta text.
  static const Color mutedGrey = Color(0xFF8A8A8A);

  /// Soft dividers on dark surfaces.
  static final Color divider = const Color(0xFFFFFFFF).withValues(alpha: 0.2);

  /// Snackbar accents.
  static const Color snackError = Color(0xFFE53935);
  static const Color snackInfo = Color(0xFF3B82F6);
}
