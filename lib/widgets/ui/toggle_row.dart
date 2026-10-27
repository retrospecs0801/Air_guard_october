import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';

/// A full-row switch control with optional leading and trailing content.
///
/// Example: `ToggleRow(title: 'Alerts', value: true, onChanged: callback)`
class ToggleRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? trailingValue;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const ToggleRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailingValue,
    required this.value,
    required this.onChanged,
    this.showDivider = false,
  });

  void _toggle() {
    HapticFeedback.selectionClick();
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.app;
    final row = Semantics(
      label: title,
      hint: subtitle,
      toggled: value,
      child: InkWell(
        onTap: _toggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.xxxl + AppSpacing.xs,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodyLarge),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                if (trailingValue != null) ...[
                  Text(trailingValue!, style: theme.textTheme.labelMedium),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Switch(
                  value: value,
                  onChanged: (_) => _toggle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        if (showDivider)
          Divider(
            color: app.border,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
      ],
    );
  }
}