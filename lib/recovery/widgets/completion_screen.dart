// lib/recovery/widgets/completion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../widgets/ui/app_card.dart';

class CompletionScreen extends StatefulWidget {
  final String exposureLevel;
  final String insight;
  final List<String> completedTasks;
  final List<String>? taskSummaries;
  final int? totalTaskCount;

  const CompletionScreen({
    super.key,
    required this.exposureLevel,
    required this.insight,
    required this.completedTasks,
    this.taskSummaries,
    this.totalTaskCount,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.app;
    final summaryItems = widget.taskSummaries ?? widget.completedTasks;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      AnimatedBuilder(
                        animation: _entryController,
                        builder: (context, child) {
                          final progress = _entryController.value;
                          final scale = Curves.elasticOut.transform(progress);
                          return SizedBox.square(
                            dimension: 152,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: (1 - progress).clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: 0.72 + (progress * 0.55),
                                    child: Container(
                                      width: 112,
                                      height: 112,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: app.aqi.good.color.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 104,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: app.aqi.good.softBackground,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: app.aqi.good.color,
                                      size: 56,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Well done', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Exposure level: ${widget.exposureLevel}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          children: [
                            Text(
                              widget.insight,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            if (summaryItems.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              const Divider(),
                              const SizedBox(height: AppSpacing.sm),
                              for (final item in summaryItems)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    item,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                            if (widget.totalTaskCount != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '${widget.completedTasks.length} of ${widget.totalTaskCount} tasks complete',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: app.aqi.good.color,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    button: true,
                    label: 'Back to home',
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Back to Home'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
