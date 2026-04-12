// lib/widgets/community/aqi_trend_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class AqiTrendChart extends StatelessWidget {
  final List<double> baselineCurve;
  final List<double> policyCurve;
  final int days;
  final String policyName;

  const AqiTrendChart({
    super.key,
    required this.baselineCurve,
    required this.policyCurve,
    required this.days,
    required this.policyName,
  });

  List<FlSpot> _toSpots(List<double> curve, int days) {
    // Sample ~10 points to keep chart smooth without too many data points
    final step = (days / 9).ceil();
    final spots = <FlSpot>[];
    for (int i = 0; i <= days; i += step) {
      if (i < curve.length) {
        spots.add(FlSpot(i.toDouble(), curve[i]));
      }
    }
    // Always include the last point
    final last = days;
    if (last < curve.length && (spots.isEmpty || spots.last.x != last.toDouble())) {
      spots.add(FlSpot(last.toDouble(), curve[last]));
    }
    return spots;
  }

  double get _maxY {
    final allValues = [...baselineCurve, ...policyCurve];
    final max = allValues.reduce((a, b) => a > b ? a : b);
    return (max * 1.1).ceilToDouble();
  }

  double get _minY {
    final allValues = [...baselineCurve, ...policyCurve];
    final min = allValues.reduce((a, b) => a < b ? a : b);
    return (min * 0.85).floorToDouble().clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final baselineSpots = _toSpots(baselineCurve, days);
    final policySpots = _toSpots(policyCurve, days);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
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
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Text(
                  'AQI Projection',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                _Legend(color: const Color(0xFFEF4444), label: 'No policy'),
                const SizedBox(width: 12),
                _Legend(color: const Color(0xFF0F766E), label: 'With policy'),
              ],
            ),
          ),
          // Chart
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: days.toDouble(),
                minY: _minY,
                maxY: _maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (_maxY - _minY) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: (_maxY - _minY) / 4,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: days == 30 ? 10 : 30,
                      getTitlesWidget: (value, _) {
                        final day = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'D$day',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  // Baseline — dashed red
                  LineChartBarData(
                    spots: baselineSpots,
                    isCurved: true,
                    color: const Color(0xFFEF4444),
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                    dashArray: [4, 4],
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Policy curve — solid teal with gradient fill
                  LineChartBarData(
                    spots: policySpots,
                    isCurved: true,
                    color: const Color(0xFF0F766E),
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, _) =>
                      spot.x == 0 || spot.x == days.toDouble(),
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                            radius: 3.5,
                            color: const Color(0xFF0F766E),
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0F766E).withOpacity(0.10),
                          const Color(0xFF0F766E).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}