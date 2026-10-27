import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';

class SegmentedTabItem<T> {
  final T value;
  final String label;

  const SegmentedTabItem({required this.value, required this.label});
}

/// A compact animated selector for a small set of mutually exclusive values.
///
/// Example: `SegmentedTabs(items: options, selected: current, onChanged: pick)`
class SegmentedTabs<T> extends StatelessWidget {
  final List<SegmentedTabItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final app = context.app;
    final selectedIndex = items.indexWhere((item) => item.value == selected);
    final activeIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final alignment = items.length == 1
        ? 0.0
        : -1.0 + (2.0 * activeIndex / (items.length - 1));

    return Semantics(
      container: true,
      child: SizedBox(
        height: AppSpacing.xxxl,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: app.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                AnimatedAlign(
                  alignment: Alignment(alignment, 0),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: constraints.maxWidth / items.length,
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: app.brandSoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          boxShadow: app.cardShadows,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var index = 0; index < items.length; index++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: index == activeIndex,
                          label: items[index].label,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            onTap: () => onChanged(items[index].value),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                                child: Text(
                                  items[index].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: index == activeIndex
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}