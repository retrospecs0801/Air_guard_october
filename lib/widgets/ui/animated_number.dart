import 'package:flutter/material.dart';

/// A smoothly tweened numeric value using tabular figures.
///
/// Example: `AnimatedNumber(value: 128.4, decimals: 1)`
class AnimatedNumber extends StatelessWidget {
  final double value;
  final int decimals;
  final TextStyle? style;
  final Duration duration;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.decimals = 0,
    this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numericStyle = (style ?? theme.textTheme.displayLarge!).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => Text(
        animatedValue.toStringAsFixed(decimals),
        style: numericStyle,
      ),
    );
  }
}