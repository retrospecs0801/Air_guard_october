// lib/recovery/widgets/task_card.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../widgets/ui/app_card.dart';
import '../models/recovery_task.dart';
import 'guided_breathing.dart';
import 'recovery_task_icon.dart';

class TaskCard extends StatelessWidget {
  final RecoveryTask task;
  final VoidCallback onComplete;
  final Animation<double>? entryAnimation;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    this.entryAnimation,
  });

  void _handleStart(BuildContext context) {
    if (task.type == TaskType.breathing) {
      // Open guided breathing screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              GuidedBreathingScreen(task: task, onComplete: onComplete),
        ),
      );
    } else {
      // For non-breathing tasks, show simple confirmation dialog
      _showTaskDialog(context);
    }
  }

  void _showTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            RecoveryTaskIconTile(task: task),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description, style: Theme.of(ctx).textTheme.bodyMedium),
            if (task.type == TaskType.doctorCTA) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your exposure score suggests medical advice is recommended. Please contact a healthcare professional if you feel unwell.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(ctx).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (task.type == TaskType.doctorCTA)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Here you could add actual phone dialer or teleconsult link
                onComplete();
              },
              child: const Text('Contact doctor'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onComplete();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.app;
    final animation = entryAnimation ?? const AlwaysStoppedAnimation(1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: Opacity(
            opacity: task.isCompleted ? 0.68 : 1,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  RecoveryTaskIconTile(task: task),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              color: app.textTertiary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              task.durationSeconds > 0
                                  ? '${task.durationSeconds} sec'
                                  : 'Anytime',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (task.isCompleted)
                    Semantics(
                      label: 'Done',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.65, end: 1),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Icon(
                              Icons.check_circle,
                              color: app.aqi.good.color,
                            ),
                          ),
                          Text('Done', style: theme.textTheme.labelSmall),
                        ],
                      ),
                    )
                  else
                    Semantics(
                      button: true,
                      label: 'Start ${task.title}',
                      child: FilledButton.tonal(
                        onPressed: () => _handleStart(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                        ),
                        child: const Text('Start'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
