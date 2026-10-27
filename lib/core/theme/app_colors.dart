import 'package:flutter/material.dart';

enum AqiLevel {
  good,
  moderate,
  unhealthySensitive,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

class AqiColorInfo {
  final AqiLevel level;
  final String label;
  final Color color;
  final Color softBackground;

  const AqiColorInfo({
    required this.level,
    required this.label,
    required this.color,
    required this.softBackground,
  });

  AqiColorInfo lerp(AqiColorInfo other, double t) => AqiColorInfo(
    level: t < 0.5 ? level : other.level,
    label: t < 0.5 ? label : other.label,
    color: Color.lerp(color, other.color, t)!,
    softBackground: Color.lerp(softBackground, other.softBackground, t)!,
  );
}

class AqiPalette {
  final AqiColorInfo good;
  final AqiColorInfo moderate;
  final AqiColorInfo unhealthySensitive;
  final AqiColorInfo unhealthy;
  final AqiColorInfo veryUnhealthy;
  final AqiColorInfo hazardous;

  const AqiPalette({
    required this.good,
    required this.moderate,
    required this.unhealthySensitive,
    required this.unhealthy,
    required this.veryUnhealthy,
    required this.hazardous,
  });

  AqiColorInfo forValue(num value) {
    final aqi = value.isFinite ? value.clamp(0, 500) : 0;
    if (aqi <= 50) return good;
    if (aqi <= 100) return moderate;
    if (aqi <= 150) return unhealthySensitive;
    if (aqi <= 200) return unhealthy;
    if (aqi <= 300) return veryUnhealthy;
    return hazardous;
  }

  AqiPalette lerp(AqiPalette other, double t) => AqiPalette(
    good: good.lerp(other.good, t),
    moderate: moderate.lerp(other.moderate, t),
    unhealthySensitive: unhealthySensitive.lerp(other.unhealthySensitive, t),
    unhealthy: unhealthy.lerp(other.unhealthy, t),
    veryUnhealthy: veryUnhealthy.lerp(other.veryUnhealthy, t),
    hazardous: hazardous.lerp(other.hazardous, t),
  );
}

class AppColorPalette {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color brand;
  final Color brandSoft;
  final Color navy;
  final Color onBrand;
  final AqiPalette aqi;

  const AppColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brand,
    required this.brandSoft,
    required this.navy,
    required this.onBrand,
    required this.aqi,
  });
}

class AppColors {
  static const light = AppColorPalette(
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF2F6),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    brand: Color(0xFF0F766E),
    brandSoft: Color(0xFFCCFBF1),
    navy: Color(0xFF1E293B),
    onBrand: Color(0xFFFFFFFF),
    aqi: AqiPalette(
      good: AqiColorInfo(
        level: AqiLevel.good,
        label: 'Good',
        color: Color(0xFF22C55E),
        softBackground: Color(0xFFDCFCE7),
      ),
      moderate: AqiColorInfo(
        level: AqiLevel.moderate,
        label: 'Moderate',
        color: Color(0xFFEAB308),
        softBackground: Color(0xFFFEF9C3),
      ),
      unhealthySensitive: AqiColorInfo(
        level: AqiLevel.unhealthySensitive,
        label: 'Unhealthy for sensitive groups',
        color: Color(0xFFF97316),
        softBackground: Color(0xFFFFEDD5),
      ),
      unhealthy: AqiColorInfo(
        level: AqiLevel.unhealthy,
        label: 'Unhealthy',
        color: Color(0xFFEF4444),
        softBackground: Color(0xFFFEE2E2),
      ),
      veryUnhealthy: AqiColorInfo(
        level: AqiLevel.veryUnhealthy,
        label: 'Very unhealthy',
        color: Color(0xFFA855F7),
        softBackground: Color(0xFFF3E8FF),
      ),
      hazardous: AqiColorInfo(
        level: AqiLevel.hazardous,
        label: 'Hazardous',
        color: Color(0xFF7F1D1D),
        softBackground: Color(0xFFFEE2E2),
      ),
    ),
  );

  static const dark = AppColorPalette(
    background: Color(0xFF0B1120),
    surface: Color(0xFF111827),
    surfaceElevated: Color(0xFF1A2233),
    surfaceMuted: Color(0xFF202B3F),
    border: Color(0xFF263145),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    brand: Color(0xFF2DD4BF),
    brandSoft: Color(0xFF134E4A),
    navy: Color(0xFF1E293B),
    onBrand: Color(0xFF0B1120),
    aqi: AqiPalette(
      good: AqiColorInfo(
        level: AqiLevel.good,
        label: 'Good',
        color: Color(0xFF4ADE80),
        softBackground: Color(0xFF123A2A),
      ),
      moderate: AqiColorInfo(
        level: AqiLevel.moderate,
        label: 'Moderate',
        color: Color(0xFFFACC15),
        softBackground: Color(0xFF423712),
      ),
      unhealthySensitive: AqiColorInfo(
        level: AqiLevel.unhealthySensitive,
        label: 'Unhealthy for sensitive groups',
        color: Color(0xFFFB923C),
        softBackground: Color(0xFF442B1A),
      ),
      unhealthy: AqiColorInfo(
        level: AqiLevel.unhealthy,
        label: 'Unhealthy',
        color: Color(0xFFF87171),
        softBackground: Color(0xFF421F2A),
      ),
      veryUnhealthy: AqiColorInfo(
        level: AqiLevel.veryUnhealthy,
        label: 'Very unhealthy',
        color: Color(0xFFC084FC),
        softBackground: Color(0xFF382044),
      ),
      hazardous: AqiColorInfo(
        level: AqiLevel.hazardous,
        label: 'Hazardous',
        color: Color(0xFFB91C1C),
        softBackground: Color(0xFF441B24),
      ),
    ),
  );

  static AqiColorInfo aqiForValue(
    num value, {
    required Brightness brightness,
  }) => (brightness == Brightness.dark ? dark : light).aqi.forValue(value);
}
