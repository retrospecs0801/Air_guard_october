// lib/recovery/models/exposure_level.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ExposureLevel { Low, Moderate, High, Critical }

class ExposureLevelHelper {
  static ExposureLevel fromScore(int score) {
    if (score <= 100) return ExposureLevel.Low; //100
    if (score <= 300) return ExposureLevel.Moderate; //250
    if (score < 500) return ExposureLevel.High; //400
    return ExposureLevel.Critical;
  }

  static String defaultDoseMessage(ExposureLevel level) {
    switch (level) {
      case ExposureLevel.Low:
        return "Low exposure — breathing exercises recommended";
      case ExposureLevel.Moderate:
        return "Moderate exposure — hydration & light movement";
      case ExposureLevel.High:
        return "High exposure — mask, diet & breathing";
      case ExposureLevel.Critical:
        return "Critical exposure — consult a doctor immediately";
    }
  }

  @Deprecated(
    'Use ExposureLevelUi.color(context) from core/theme/exposure_level_ui.dart',
  )
  static Color getLevelColor(ExposureLevel level) {
    switch (level) {
      case ExposureLevel.Low:
        return AppColors.light.aqi.good.color;
      case ExposureLevel.Moderate:
        return AppColors.light.aqi.moderate.color;
      case ExposureLevel.High:
        return AppColors.light.aqi.unhealthy.color;
      case ExposureLevel.Critical:
        return AppColors.light.aqi.hazardous.color;
    }
  }

  static String getLevelName(ExposureLevel level) {
    switch (level) {
      case ExposureLevel.Low:
        return "Low";
      case ExposureLevel.Moderate:
        return "Moderate";
      case ExposureLevel.High:
        return "High";
      case ExposureLevel.Critical:
        return "Critical";
    }
  }
}
