import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color brand;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color border;
  final Color textTertiary;
  final Color brandSoft;
  final AqiPalette aqi;
  final List<BoxShadow> cardShadows;

  const AppThemeExtension({
    required this.brand,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.border,
    required this.textTertiary,
    required this.brandSoft,
    required this.aqi,
    required this.cardShadows,
  });

  AqiColorInfo aqiForValue(num value) => aqi.forValue(value);

  @override
  AppThemeExtension copyWith({
    Color? brand,
    Color? textPrimary,
    Color? textSecondary,
    Color? surfaceElevated,
    Color? surfaceMuted,
    Color? border,
    Color? textTertiary,
    Color? brandSoft,
    AqiPalette? aqi,
    List<BoxShadow>? cardShadows,
  }) => AppThemeExtension(
    brand: brand ?? this.brand,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    border: border ?? this.border,
    textTertiary: textTertiary ?? this.textTertiary,
    brandSoft: brandSoft ?? this.brandSoft,
    aqi: aqi ?? this.aqi,
    cardShadows: cardShadows ?? this.cardShadows,
  );

  @override
  AppThemeExtension lerp(covariant AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      brand: Color.lerp(brand, other.brand, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      aqi: aqi.lerp(other.aqi, t),
      cardShadows:
          BoxShadow.lerpList(cardShadows, other.cardShadows, t) ?? cardShadows,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get app => Theme.of(this).extension<AppThemeExtension>()!;
}
