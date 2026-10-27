import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';

enum InfoBannerTone { info, warning, success, error }

/// A themed message surface with an optional action.
///
/// Example: `InfoBanner(title: 'Location needed', message: 'Enable access.')`
class InfoBanner extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final InfoBannerTone tone;

  const InfoBanner({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = InfoBannerTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.app;
    final status = switch (tone) {
      InfoBannerTone.info => (theme.colorScheme.primary, app.brandSoft),
      InfoBannerTone.warning => (app.aqi.moderate.color, app.aqi.moderate.softBackground),
      InfoBannerTone.success => (app.aqi.good.color, app.aqi.good.softBackground),
      InfoBannerTone.error => (app.aqi.unhealthy.color, app.aqi.unhealthy.softBackground),
    };
    final bannerIcon = icon ?? switch (tone) {
      InfoBannerTone.info => Icons.info_outline,
      InfoBannerTone.warning => Icons.warning_amber,
      InfoBannerTone.success => Icons.check_circle_outline,
      InfoBannerTone.error => Icons.error_outline,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.$2,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(bannerIcon, color: status.$1),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(message, style: theme.textTheme.bodySmall),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Semantics(
                    button: true,
                    label: actionLabel,
                    child: TextButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}