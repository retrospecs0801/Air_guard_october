import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';

enum AppCardTone { neutral, brand, aqiLevel }

/// A softly elevated surface with optional tap feedback.
///
/// Example: `AppCard(child: const Text('Air quality details'))`
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final AppCardTone tone;
  final AqiLevel? aqiLevel;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.tone = AppCardTone.neutral,
    this.aqiLevel,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final palette = Theme.of(context).colorScheme;
    final background = switch (tone) {
      AppCardTone.neutral => app.surfaceElevated,
      AppCardTone.brand => app.brandSoft,
      AppCardTone.aqiLevel => _aqiColors(app.aqi, aqiLevel).softBackground,
    };

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: app.cardShadows,
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : Semantics(
                button: true,
                child: InkWell(
                  onTap: onTap,
                  overlayColor: WidgetStatePropertyAll(
                    palette.primary.withValues(alpha: 0.08),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.xxxl,
                    ),
                    child: content,
                  ),
                ),
              ),
      ),
    );
  }

  static AqiColorInfo _aqiColors(AqiPalette palette, AqiLevel? level) {
    return switch (level ?? AqiLevel.good) {
      AqiLevel.good => palette.good,
      AqiLevel.moderate => palette.moderate,
      AqiLevel.unhealthySensitive => palette.unhealthySensitive,
      AqiLevel.unhealthy => palette.unhealthy,
      AqiLevel.veryUnhealthy => palette.veryUnhealthy,
      AqiLevel.hazardous => palette.hazardous,
    };
  }
}