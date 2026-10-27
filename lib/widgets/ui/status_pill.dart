import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';

/// A readable status label, optionally styled from the AQI palette.
///
/// Example: `StatusPill.aqi(42)`
class StatusPill extends StatelessWidget {
  final String? _label;
  final Color? _color;
  final Color? _soft;
  final num? _aqi;

  const StatusPill({
    super.key,
    required String label,
    Color? color,
    Color? soft,
  }) : _label = label,
       _color = color,
       _soft = soft,
       _aqi = null;

  const StatusPill.aqi(
    int aqi, {
    super.key,
  }) : _label = null,
       _color = null,
       _soft = null,
       _aqi = aqi;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final theme = Theme.of(context);
    final aqiInfo = _aqi == null ? null : app.aqiForValue(_aqi);
    final foreground = _color ?? aqiInfo?.color ?? theme.colorScheme.primary;
    final background =
        _soft ?? aqiInfo?.softBackground ?? app.surfaceMuted;
    final label = _label ?? aqiInfo!.label;

    return Semantics(
      label: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.xl),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: foreground),
        ),
      ),
    );
  }
}