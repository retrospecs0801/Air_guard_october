// lib/recovery/recovery_screen.dart
import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme_extension.dart';
import '../core/theme/exposure_level_ui.dart';
import '../widgets/ui/ui.dart';
import 'models/exposure_level.dart';
import 'models/recovery_task.dart';
import 'widgets/task_card.dart';
import 'widgets/completion_screen.dart';
import 'services/gemini_service.dart';
import 'widgets/recovery_task_icon.dart';

class RecoveryScreen extends StatefulWidget {
  final int pollutionDose;
  final String doseMessage;

  const RecoveryScreen({
    super.key,
    required this.pollutionDose,
    required this.doseMessage,
  });

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen>
    with TickerProviderStateMixin {
  late ExposureLevel exposureLevel;
  late List<RecoveryTask> tasks;
  bool isRecoveryStarted = false;
  late AnimationController _gaugeController;
  late AnimationController _taskListController;

  @override
  void initState() {
    super.initState();
    exposureLevel = ExposureLevelHelper.fromScore(widget.pollutionDose);
    tasks = RecoveryTask.getTasksForLevel(
      ExposureLevelHelper.getLevelName(exposureLevel),
    );
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _taskListController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300 + 40 * (tasks.length - 1).clamp(0, 20),
      ),
    );
  }

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  bool get allTasksCompleted =>
      tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

  void _startRecovery() {
    setState(() {
      isRecoveryStarted = true;
    });
    _taskListController.forward(from: 0);
  }

  Future<void> _completeRecovery() async {
    // Generate insight message
    final levelName = ExposureLevelHelper.getLevelName(exposureLevel);
    final completedTaskTitles = tasks
        .where((t) => t.isCompleted)
        .map((t) => t.title)
        .toList();

    final insight = await GeminiService.generateInsight(
      exposureLevel: levelName,
      score: widget.pollutionDose,
      completedTasks: completedTaskTitles,
    );

    if (!mounted) return;

    // Navigate to completion screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CompletionScreen(
          exposureLevel: levelName,
          insight: insight,
          completedTasks: completedTaskTitles,
          taskSummaries: tasks
              .where((task) => task.isCompleted)
              .map(
                (task) => task.durationSeconds > 0
                    ? '${task.title} - ${task.durationSeconds} sec'
                    : task.title,
              )
              .toList(),
          totalTaskCount: tasks.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery plan')),
      body: isRecoveryStarted ? _buildTaskList() : _buildSummaryScreen(),
    );
  }

  Widget _buildSummaryScreen() {
    final theme = Theme.of(context);
    final app = context.app;
    final exposureInfo = exposureLevel.info(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _gaugeController,
                        builder: (context, _) => SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: _ExposureGaugePainter(
                              color: exposureInfo.color,
                              progress: Curves.easeOutCubic.transform(
                                _gaugeController.value,
                              ),
                              trackColor: app.surfaceMuted,
                            ),
                            child: Center(
                              child: AnimatedNumber(
                                value: widget.pollutionDose.toDouble(),
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StatusPill(
                        label: ExposureLevelHelper.getLevelName(exposureLevel),
                        color: exposureInfo.color,
                        soft: exposureInfo.softBackground,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Reverse effects of pollution you consumed today',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.doseMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SectionHeader(
                  title: 'Recovery tasks',
                  subtitle: '${tasks.length} tasks for your exposure level',
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var index = 0; index < tasks.length; index++) ...[
                        if (index > 0) const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              RecoveryTaskIconTile(task: tasks[index]),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  tasks[index].title,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                tasks[index].durationSeconds > 0
                                    ? '${tasks[index].durationSeconds} sec'
                                    : 'Anytime',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
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
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: 'Start recovery',
                child: FilledButton(
                  onPressed: _startRecovery,
                  child: const Text('Start recovery'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final theme = Theme.of(context);
    final app = context.app;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your recovery tasks',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '$completedTasksCount of ${tasks.length}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: tasks.isEmpty ? 0 : completedTasksCount / tasks.length,
                  ),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    color: theme.colorScheme.primary,
                    backgroundColor: app.surfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final totalDuration =
                  _taskListController.duration!.inMilliseconds;
              final start = (40 * index) / totalDuration;
              final end = ((40 * index) + 300) / totalDuration;
              final animation = CurvedAnimation(
                parent: _taskListController,
                curve: Interval(
                  start.clamp(0.0, 1.0),
                  end.clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              );
              return TaskCard(
                task: task,
                entryAnimation: animation,
                onComplete: () {
                  setState(() {
                    task.isCompleted = true;
                  });
                  if (allTasksCompleted) {
                    _completeRecovery();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _taskListController.dispose();
    super.dispose();
  }
}

class _ExposureGaugePainter extends CustomPainter {
  final Color color;
  final Color trackColor;
  final double progress;

  const _ExposureGaugePainter({
    required this.color,
    required this.trackColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -1.5708, 6.2832, false, trackPaint);
    canvas.drawArc(rect, -1.5708, 6.2832 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ExposureGaugePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progress != progress;
}
