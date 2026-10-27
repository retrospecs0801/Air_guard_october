// lib/recovery/widgets/guided_breathing.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';
import '../models/recovery_task.dart';

class GuidedBreathingScreen extends StatefulWidget {
  final RecoveryTask task;
  final VoidCallback onComplete;

  const GuidedBreathingScreen({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<GuidedBreathingScreen> createState() => _GuidedBreathingScreenState();
}

class _GuidedBreathingScreenState extends State<GuidedBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _timer;
  int _remainingSeconds = 0;
  String _currentPhase = 'Inhale';
  bool _isRunning = false;
  bool _hasStarted = false;

  final List<Map<String, Object>> _breathingCycle = [
    {'phase': 'Inhale', 'duration': 4},
    {'phase': 'Hold', 'duration': 4},
    {'phase': 'Exhale', 'duration': 4},
    {'phase': 'Hold', 'duration': 4},
  ];

  int _currentCycleIndex = 0;
  int _cyclesCompleted = 0;
  final int _totalCycles = 4;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.task.durationSeconds;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
      _hasStarted = true;
    });
    _runBreathingCycle();
  }

  void _runBreathingCycle() {
    final cycle = _breathingCycle[_currentCycleIndex];
    final phase = cycle['phase'] as String;
    final duration = cycle['duration'] as int;
    if (_currentPhase != phase) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _currentPhase = phase;
    });

    _animationController
      ..duration = Duration(seconds: duration)
      ..value = 0
      ..forward();

    _timer = Timer(Duration(seconds: duration), () {
      if (!mounted) return;

      setState(() {
        _currentCycleIndex = (_currentCycleIndex + 1) % _breathingCycle.length;
        _remainingSeconds = math.max(0, _remainingSeconds - duration);

        if (_currentCycleIndex == 0) {
          _cyclesCompleted++;
        }
      });
      if (_cyclesCompleted >= _totalCycles || _remainingSeconds <= 0) {
        _completeExercise();
      } else {
        _runBreathingCycle();
      }
    });
  }

  void _completeExercise() {
    _timer?.cancel();
    _animationController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle),
            SizedBox(width: AppSpacing.sm),
            Text('Great work!'),
          ],
        ),
        content: const Text(
          'You completed the breathing exercise. Deep breathing helps clear your airways and reduces pollution effects.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onComplete();
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _pauseBreathing() {
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.app;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              Color.lerp(theme.scaffoldBackgroundColor, app.brandSoft, 0.38)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'End session',
                      child: IconButton(
                        tooltip: 'End session',
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        widget.task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(_displayRemainingSeconds),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text('remaining', style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final orbSize = math.min(240.0, constraints.maxWidth - 48);
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, _) {
                                final progress = Curves.easeInOutSine.transform(
                                  _animationController.value,
                                );
                                final animatedScale =
                                    switch (_currentCycleIndex) {
                                      0 => 0.84 + (0.16 * progress),
                                      1 => 1.0,
                                      2 => 1.0 - (0.16 * progress),
                                      _ => 0.84,
                                    };
                                final staticScale =
                                    switch (_currentCycleIndex) {
                                      0 || 1 => 1.0,
                                      _ => 0.84,
                                    };
                                return SizedBox.square(
                                  dimension: orbSize + 32,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: orbSize + 32,
                                        height: orbSize + 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.12),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: orbSize + 16,
                                        height: orbSize + 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: disableAnimations
                                            ? staticScale
                                            : animatedScale,
                                        child: Container(
                                          width: orbSize,
                                          height: orbSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                theme.colorScheme.primary,
                                                theme.colorScheme.primary
                                                    .withValues(alpha: 0.82),
                                                app.brandSoft,
                                              ],
                                              stops: const [0, 0.68, 1],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.22),
                                                blurRadius: 44,
                                                spreadRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.air,
                                            color: theme.colorScheme.onPrimary,
                                            size: orbSize * 0.28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _currentPhase,
                                key: ValueKey(_currentPhase),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, _) => Text(
                                '${_displayPhaseSeconds}s',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _isRunning
                                  ? 'Cycle ${_cyclesCompleted + 1}/$_totalCycles'
                                  : widget.task.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) {
                        final progress = widget.task.durationSeconds <= 0
                            ? 0.0
                            : 1 -
                                  (_displayRemainingSeconds /
                                      widget.task.durationSeconds);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 6,
                            color: theme.colorScheme.primary,
                            backgroundColor: app.surfaceMuted,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!_isRunning)
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: _hasStarted
                              ? 'Resume breathing'
                              : 'Start breathing',
                          child: FilledButton.icon(
                            onPressed: _startBreathing,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(_hasStarted ? 'Resume' : 'Start'),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Pause breathing',
                            child: FilledButton.tonalIcon(
                              onPressed: _pauseBreathing,
                              icon: const Icon(Icons.pause),
                              label: const Text('Pause'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Semantics(
                            button: true,
                            label: 'Skip breathing exercise',
                            child: OutlinedButton.icon(
                              onPressed: _completeExercise,
                              icon: const Icon(Icons.skip_next),
                              label: const Text('Skip'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _phaseDuration =>
      _breathingCycle[_currentCycleIndex]['duration'] as int;

  int get _displayPhaseSeconds {
    if (!_isRunning) return _phaseDuration;
    return (_phaseDuration -
            (_animationController.value * _phaseDuration).floor())
        .clamp(1, _phaseDuration);
  }

  int get _displayRemainingSeconds {
    if (!_isRunning) return _remainingSeconds;
    final elapsed = (_animationController.value * _phaseDuration).floor();
    return (_remainingSeconds - elapsed).clamp(0, _remainingSeconds);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }
}
