import 'package:flutter/material.dart';

import '../../recovery/models/exposure_level.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

extension ExposureLevelUi on ExposureLevel {
  AqiColorInfo info(BuildContext context) {
    final palette = context.app.aqi;
    return switch (this) {
      ExposureLevel.Low => palette.good,
      ExposureLevel.Moderate => palette.moderate,
      ExposureLevel.High => palette.unhealthy,
      ExposureLevel.Critical => palette.hazardous,
    };
  }

  Color color(BuildContext context) => info(context).color;

  Color softColor(BuildContext context) => info(context).softBackground;

  String label(BuildContext context) => info(context).label;
}
