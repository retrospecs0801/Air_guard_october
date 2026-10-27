import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A compact metric with tabular figures and an optional color accent.
///
/// Example: `StatTile(icon: Icons.air, label: 'AQI', value: '42')`
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color? accent;

  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor = accent ?? theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent ?? theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: theme.textTheme.displayMedium?.copyWith(color: valueColor),
        ),
        if (caption != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(caption!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}