import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Global Material theme tuned for a premium, iOS-like feel.
///
/// [themed] follows the active [AppColors.brightness], which the app root sets
/// from the persisted light/dark preference before each build.
class AppTheme {
  AppTheme._();

  static ThemeData get themed {
    final dark = AppColors.isDark;
    final brightness = dark ? Brightness.dark : Brightness.light;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandStart,
        brightness: brightness,
        primary: AppColors.brandStart,
        surface: AppColors.surface,
      ),
      fontFamily: 'SFPro', // Falls back to system font if not bundled.
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
      ),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandStart,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
