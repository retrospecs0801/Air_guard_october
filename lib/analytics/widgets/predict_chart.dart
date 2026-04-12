// lib/analytics/widgets/predict_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/analytics_data.dart';

enum ChartMode { actual, predicted, simulated }

// ─────────────────────────────────────────────────────────
// Weekly bar chart
// ─────────────────────────────────────────────────────────
class PredictWeeklyChart extends StatefulWidget {
  final List<DailyExposure> data;
  final ChartMode mode;

  const PredictWeeklyChart({
    Key? key,
    required this.data,
    required this.mode,
  }) : super(key: key);

  @override
  State<PredictWeeklyChart> createState() => _PredictWeeklyChartState();
}

class _PredictWeeklyChartState extends State<PredictWeeklyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(PredictWeeklyChart old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.data.length != widget.data.length) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Daily Exposure',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (widget.mode != ChartMode.actual) _modeBadge(),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 500,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex =
                        (!event.isInterestedForInteractions ||
                            response?.spot == null)
                            ? -1
                            : response!.spot!.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.navy,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      tooltipMargin: 8,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final d = widget.data[groupIndex];
                        final tag = d.isSimulated
                            ? 'Protected'
                            : d.isPrediction
                            ? 'Predicted'
                            : 'Actual';
                        return BarTooltipItem(
                          '${d.dayName} · $tag\n',
                          const TextStyle(
                              color: Colors.white60, fontSize: 10),
                          children: [
                            TextSpan(
                              text: '${d.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= widget.data.length) {
                            return const Text('');
                          }
                          final d = widget.data[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              d.dayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: d.isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: d.isPrediction
                                    ? const Color(0xFF6366F1)
                                    : d.isToday
                                    ? AppColors.navy
                                    : AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 100 ||
                              value == 200 || value == 300 || value == 400) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textMuted),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                          color: AppColors.borderLight, width: 1),
                      left: BorderSide(
                          color: AppColors.borderLight, width: 1),
                    ),
                  ),
                  barGroups: _buildBarGroups(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 450),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
            const SizedBox(height: 14),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final idx = entry.key;
      final d   = entry.value;
      final isTouched = idx == _touchedIndex;

      Color barColor;
      double opacity;
      BorderSide border;

      if (d.isSimulated) {
        barColor = AppColors.teal;
        opacity  = d.isPrediction ? 0.6 : 1.0;
        border   = const BorderSide(color: AppColors.teal, width: 1);
      } else if (d.isPrediction) {
        barColor = d.color;
        opacity  = 0.20;
        border   = BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.5), width: 1.5);
      } else {
        barColor = d.color;
        opacity  = 1.0;
        border   = d.isToday
            ? const BorderSide(color: AppColors.navy, width: 2)
            : BorderSide.none;
      }

      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: d.score * _anim.value,
            color: barColor.withOpacity(opacity),
            width: 26,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(5)),
            borderSide: isTouched
                ? BorderSide(color: barColor, width: 2)
                : border,
            backDrawRodData: d.isPrediction && !d.isSimulated
                ? BackgroundBarChartRodData(
              show: true,
              toY: 500,
              color: const Color(0xFF6366F1).withOpacity(0.03),
            )
                : null,
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  Widget _modeBadge() {
    final isPred = widget.mode == ChartMode.predicted;
    final color  = isPred ? const Color(0xFF6366F1) : AppColors.teal;
    final label  = isPred ? 'Predicted' : 'Simulated';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _dot(AppColors.good, 'Low (0-100)'),
        _dot(AppColors.moderate, 'Moderate (101-250)'),
        _dot(AppColors.high, 'High (251-400)'),
        if (widget.mode == ChartMode.predicted ||
            widget.mode == ChartMode.simulated)
          _dot(const Color(0xFF6366F1).withOpacity(0.4), 'Predicted',
              dashed: true),
        if (widget.mode == ChartMode.simulated)
          _dot(AppColors.teal, 'Protected'),
      ],
    );
  }

  Widget _dot(Color color, String label, {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dashed ? color.withOpacity(0.3) : color,
            borderRadius: BorderRadius.circular(2),
            border: dashed
                ? Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.6),
                width: 1.2)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Monthly line chart
// ─────────────────────────────────────────────────────────
class PredictMonthlyChart extends StatefulWidget {
  final List<DailyExposure> data;
  final ChartMode mode;

  const PredictMonthlyChart({
    Key? key,
    required this.data,
    required this.mode,
  }) : super(key: key);

  @override
  State<PredictMonthlyChart> createState() => _PredictMonthlyChartState();
}

class _PredictMonthlyChartState extends State<PredictMonthlyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(PredictMonthlyChart old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.data.length != widget.data.length) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '30-Day Trend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (widget.mode != ChartMode.actual) _modeBadge(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => LineChart(
                _buildLineData(),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildWeeklySummary(),
        ],
      ),
    );
  }

  LineChartData _buildLineData() {
    final actual    = widget.data.where((d) => !d.isPrediction).toList();
    final predicted = widget.data.where((d) => d.isPrediction).toList();
    final offset    = actual.length;

    final actualSpots = actual.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.score * _anim.value))
        .toList();

    final predSpots = predicted.asMap().entries
        .map((e) => FlSpot(
        (offset + e.key).toDouble(), e.value.score * _anim.value))
        .toList();

    final connectedPredSpots = predSpots.isNotEmpty
        ? [if (actualSpots.isNotEmpty) actualSpots.last, ...predSpots]
        : <FlSpot>[];

    final lines = <LineChartBarData>[];
    final mainColor =
    widget.mode == ChartMode.simulated ? AppColors.teal : AppColors.high;

    if (actualSpots.isNotEmpty) {
      lines.add(LineChartBarData(
        spots: actualSpots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: mainColor,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, pct, bar, idx) {
            final d = actual[idx];
            return FlDotCirclePainter(
              radius: d.isToday ? 5 : 2.5,
              color: widget.mode == ChartMode.simulated
                  ? AppColors.teal
                  : d.color,
              strokeWidth: d.isToday ? 2 : 0,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              mainColor.withOpacity(0.15),
              mainColor.withOpacity(0.01),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ));
    }

    if (connectedPredSpots.isNotEmpty) {
      final predColor = widget.mode == ChartMode.simulated
          ? AppColors.teal
          : const Color(0xFF6366F1);
      lines.add(LineChartBarData(
        spots: connectedPredSpots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: predColor.withOpacity(0.5),
        barWidth: 2,
        dashArray: widget.mode == ChartMode.simulated ? null : [6, 4],
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
            radius: 2.5,
            color: predColor.withOpacity(0.5),
            strokeWidth: 0,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              predColor.withOpacity(0.08),
              predColor.withOpacity(0.01),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ));
    }

    return LineChartData(
      minY: 0,
      maxY: 500,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.navy,
          tooltipPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          tooltipRoundedRadius: 8,
          getTooltipItems: (spots) => spots.map((spot) {
            final idx = spot.x.toInt();
            if (idx < 0 || idx >= widget.data.length) return null;
            final d   = widget.data[idx];
            final tag = d.isSimulated
                ? 'Protected'
                : d.isPrediction
                ? 'Predicted'
                : 'Actual';
            return LineTooltipItem(
              '${d.date.day}/${d.date.month} · $tag\n',
              const TextStyle(color: Colors.white60, fontSize: 10),
              children: [
                TextSpan(
                  text: '${d.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 100,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: AppColors.divider,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 7,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= widget.data.length) return const Text('');
              final isPred = widget.data[idx].isPrediction;
              final label  = isPred ? 'P${(idx - 30) ~/ 7 + 1}' : 'Wk${(idx ~/ 7) + 1}';
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isPred
                        ? const Color(0xFF6366F1).withOpacity(0.7)
                        : AppColors.textSecondary,
                    fontWeight: isPred
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 100,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textMuted),
            ),
          ),
        ),
        topTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
          left:   BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      lineBarsData: lines,
    );
  }

  Widget _modeBadge() {
    final isPred = widget.mode == ChartMode.predicted;
    final color  = isPred ? const Color(0xFF6366F1) : AppColors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        isPred ? 'Predicted' : 'Simulated',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildWeeklySummary() {
    final chunks = <_WeekChunk>[];
    for (int i = 0; i < widget.data.length; i += 7) {
      final chunk = widget.data.skip(i).take(7).toList();
      if (chunk.isEmpty) continue;
      final avg   = chunk.map((e) => e.score).reduce((a, b) => a + b) / chunk.length;
      chunks.add(_WeekChunk(
        num: (i ~/ 7) + 1,
        avg: avg.round(),
        isPred: chunk.any((e) => e.isPrediction),
        isSim:  chunk.any((e) => e.isSimulated),
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chunks.map((c) {
        Color color;
        if (c.isSim)       color = AppColors.teal;
        else if (c.isPred) color = const Color(0xFF6366F1);
        else if (c.avg <= 100)  color = AppColors.good;
        else if (c.avg <= 250)  color = AppColors.moderate;
        else                    color = AppColors.high;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: Text(
            '${c.isPred && !c.isSim ? "↑ " : c.isSim ? "↓ " : ""}Wk${c.num}: ${c.avg}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekChunk {
  final int num, avg;
  final bool isPred, isSim;
  _WeekChunk({required this.num, required this.avg,
    required this.isPred, required this.isSim});
}