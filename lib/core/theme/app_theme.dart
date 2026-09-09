import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newlane/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryButtonBg, 
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.montserratTextTheme(),
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryButtonBg),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryButtonBg,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}

