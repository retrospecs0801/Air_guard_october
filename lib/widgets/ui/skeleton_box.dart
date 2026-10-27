import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme_extension.dart';

/// A theme-aware placeholder that shimmers while its subtree is active.
///
/// Example: `const SkeletonBox(width: 160, height: 16)`
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _tickerEnabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.valuesOf(context).enabled;
    if (enabled == _tickerEnabled) return;
    _tickerEnabled = enabled;
    if (enabled) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = -1.5 + (3 * _controller.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(shift, 0),
                end: Alignment(-shift, 0),
                colors: [app.surfaceMuted, app.surfaceElevated, app.surfaceMuted],
                stops: const [0.2, 0.5, 0.8],
              ),
            ),
            child: SizedBox(width: widget.width, height: widget.height),
          ),
        );
      },
    );
  }
}