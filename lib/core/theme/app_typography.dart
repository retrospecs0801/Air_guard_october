import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

  static TextTheme forPalette(AppColorPalette palette) => TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 56,
      height: 1,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: palette.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 44,
      height: 1.05,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: palette.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w700,
      color: palette.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: palette.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: palette.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: palette.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: palette.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: palette.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: palette.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: palette.textSecondary,
    ),
  );
}
