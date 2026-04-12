// lib/analytics/models/analytics_data.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
// ─────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────
class AppColors {
  static const background    = Color(0xFFF4F6F8);
  static const cardBg        = Color(0xFFFFFFFF);
  static const navy          = Color(0xFF1E293B);
  static const teal          = Color(0xFF0F766E);
  static const slate         = Color(0xFF4B5563);
  static const red           = Color(0xFFEF4444);
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted     = Color(0xFF9CA3AF);
  static const divider       = Color(0xFFF3F4F6);
  static const borderLight   = Color(0xFFE5E7EB);
  static const good          = Color(0xFF22C55E);
  static const goodBg        = Color(0xFFF0FDF4);
  static const moderate      = Color(0xFFF59E0B);
  static const moderateBg    = Color(0xFFFFFBEB);
  static const high          = Color(0xFFEF4444);
  static const highBg        = Color(0xFFFEF2F2);
}

// ─────────────────────────────────────────────────────────
// Precaution model
// ─────────────────────────────────────────────────────────
class Precaution {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final double reductionCoefficient; // NOT shown in UI

  bool isSelected;
  double? impactPercent;
  int?    rank;

  Precaution({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.reductionCoefficient,
    this.isSelected = true,
  });
}

// ─────────────────────────────────────────────────────────
// FIX 4 — Recalibrated coefficients (soft cap ≈ 69% max)
// Base * (1-0.25)*(1-0.20)*(1-0.18)*(1-0.15)*(1-0.12)*(1-0.10)*(1-0.08)
// = Base * 0.312  →  68.8% max reduction
// ─────────────────────────────────────────────────────────
class PrecautionRegistry {
  static List<Precaution> defaults() => [
    Precaution(
      id: 'n95',
      title: 'Wear N95 Mask',
      subtitle: 'Blocks fine particulate matter outdoors',
      icon: '😷',
      reductionCoefficient: 0.25,   // was 0.45
    ),
    Precaution(
      id: 'purifier',
      title: 'Use Indoor Air Purifier',
      subtitle: 'HEPA filter running during high AQI hours',
      icon: '💨',
      reductionCoefficient: 0.18,   // was 0.32
    ),
    Precaution(
      id: 'outdoor_time',
      title: 'Reduce Outdoor Time',
      subtitle: 'Cut outdoor exposure by half',
      icon: '🏠',
      reductionCoefficient: 0.20,   // was 0.35
    ),
    Precaution(
      id: 'peak_hours',
      title: 'Avoid Peak AQI Hours',
      subtitle: 'Stay indoors 8–11 AM and 5–8 PM',
      icon: '⏰',
      reductionCoefficient: 0.08,   // was 0.13
    ),
    Precaution(
      id: 'windows',
      title: 'Close Windows',
      subtitle: 'During high AQI periods',
      icon: '🪟',
      reductionCoefficient: 0.12,   // was 0.20
    ),
    Precaution(
      id: 'route',
      title: 'Choose Cleaner Routes',
      subtitle: 'Avoid high-traffic and industrial roads',
      icon: '🗺️',
      reductionCoefficient: 0.15,   // was 0.25
    ),
    Precaution(
      id: 'kitchen',
      title: 'Improve Kitchen Ventilation',
      subtitle: 'Exhaust fan on while cooking',
      icon: '🍳',
      reductionCoefficient: 0.10,   // was 0.15
    ),
  ];
}

// ─────────────────────────────────────────────────────────
// Simulation result
// ─────────────────────────────────────────────────────────
class SimulationResult {
  final double baselineExposure;
  final double finalExposure;
  final double totalReductionPercent;
  final List<Precaution> rankedPrecautions;

  SimulationResult({
    required this.baselineExposure,
    required this.finalExposure,
    required this.totalReductionPercent,
    required this.rankedPrecautions,
  });
}

// ─────────────────────────────────────────────────────────
// DailyExposure — immutable value object
// ─────────────────────────────────────────────────────────
class DailyExposure {
  final DateTime date;
  final int      score;
  final String   dayName;
  final bool     isToday;
  final bool     isPrediction;
  final bool     isSimulated;

  const DailyExposure({
    required this.date,
    required this.score,
    required this.dayName,
    this.isToday     = false,
    this.isPrediction = false,
    this.isSimulated  = false,
  });

  Color get color {
    if (isSimulated)   return AppColors.teal;
    if (isPrediction)  return const Color(0xFF6366F1);
    if (score <= 100)  return AppColors.good;
    if (score <= 250)  return AppColors.moderate;
    if (score <= 400)  return AppColors.high;
    return const Color(0xFF7C3AED);
  }

  String get levelName {
    if (score <= 100)  return 'Low';
    if (score <= 250)  return 'Moderate';
    if (score <= 400)  return 'High';
    return 'Critical';
  }
}

// ─────────────────────────────────────────────────────────
// AnalyticsPeriod
// ─────────────────────────────────────────────────────────
class AnalyticsPeriod {
  final List<DailyExposure> data;
  final String insight;
  final double averageScore;
  final String trend;
  final int    worstDayScore;
  final String worstDayName;
  final int    safeDaysCount;
  final double comparisonPercentage;

  AnalyticsPeriod({
    required this.data,
    required this.insight,
    required this.averageScore,
    required this.trend,
    required this.worstDayScore,
    required this.worstDayName,
    required this.safeDaysCount,
    required this.comparisonPercentage,
  });

  IconData get trendIcon {
    if (trend == 'increasing') return Icons.trending_up;
    if (trend == 'decreasing') return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color get trendColor {
    if (trend == 'increasing') return AppColors.high;
    if (trend == 'decreasing') return AppColors.good;
    return AppColors.textMuted;
  }
}

// ─────────────────────────────────────────────────────────
// FIX 1 — Mock data: gradual monthly trend, avg ~260–280
// ─────────────────────────────────────────────────────────
class MockAnalyticsData {
  static AnalyticsPeriod getWeeklyData() {
    final now    = DateTime.now();
    final today  = DateTime(now.year, now.month, now.day);
    final friday = today.subtract(Duration(days: today.weekday - 5));

    final weekData = [
      DailyExposure(date: friday.subtract(const Duration(days: 4)), score: 240, dayName: 'Mon'),
      DailyExposure(date: friday.subtract(const Duration(days: 3)), score: 255, dayName: 'Tue'),
      DailyExposure(date: friday.subtract(const Duration(days: 2)), score: 262, dayName: 'Wed'),
      DailyExposure(date: friday.subtract(const Duration(days: 1)), score: 270, dayName: 'Thu'),
      DailyExposure(date: friday,                                    score: 278, dayName: 'Fri', isToday: true),
      DailyExposure(date: friday.add(const Duration(days: 1)),       score: 0,   dayName: 'Sat'),
      DailyExposure(date: friday.add(const Duration(days: 2)),       score: 0,   dayName: 'Sun'),
    ];

    final actual = weekData.where((e) => e.score > 0).toList();
    final avg    = actual.map((e) => e.score).reduce((a, b) => a + b) / actual.length;
    final worst  = actual.reduce((a, b) => a.score > b.score ? a : b);

    return AnalyticsPeriod(
      data: weekData,
      insight: 'Moderate exposure — gradual upward trend',
      averageScore: avg,
      trend: 'increasing',
      worstDayScore: worst.score,
      worstDayName: worst.dayName,
      safeDaysCount: 0,
      comparisonPercentage: 12,   // was 39% — now realistic
    );
  }

  static AnalyticsPeriod getMonthlyData() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final data  = <DailyExposure>[];

    // FIX 1 — Very gradual rise from ~230 to ~285 over 30 days
    // Total rise = ~55 points over 30 days = ~1.8 pts/day
    for (int i = 29; i >= 0; i--) {
      final date    = today.subtract(Duration(days: i));
      final dayName = _dayName(date.weekday);

      // Base rises gradually from 230 to 285
      final base = 230 + ((29 - i) * 1.85).round();
      // Add small daily variation (±8) so it looks natural not perfectly linear
      final variation = (((i * 7) + date.weekday * 3) % 17) - 8;
      final score     = (base + variation).clamp(210, 300);

      data.add(DailyExposure(
          date: date, score: score, dayName: dayName, isToday: i == 0));
    }

    final avg   = data.map((e) => e.score).reduce((a, b) => a + b) / data.length;
    final worst = data.reduce((a, b) => a.score > b.score ? a : b);
    final safe  = data.where((e) => e.score <= 100).length;

    return AnalyticsPeriod(
      data: data,
      insight: 'Gradual upward trend over 30 days',
      averageScore: avg,
      trend: 'increasing',
      worstDayScore: worst.score,
      worstDayName: worst.dayName,
      safeDaysCount: safe,
      comparisonPercentage: 10,   // was 28% — now realistic
    );
  }

  static String _dayName(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][(w - 1).clamp(0, 6)];
}

// ─────────────────────────────────────────────────────────
// Prediction + Simulation Engine
// ─────────────────────────────────────────────────────────
class PredictionEngine {

  // ── Weekly: extrapolate Sat & Sun only ────────────────────
  static List<DailyExposure> generateWeeklyPrediction(AnalyticsPeriod p) {
    final actual = p.data.where((e) => e.score > 0).toList();
    // FIX 2 — Use a dampened slope so prediction stays gradual
    final rawSlope    = _slope(actual);
    final dampedSlope = rawSlope * 0.8; // dampen so it doesn't spike
    int step = 0;

    return p.data.map((e) {
      if (e.score > 0) return e; // historical — untouched
      step++;
      // FIX 2 — clamp within realistic range (never > 380 for weekly)
      final predicted = (actual.last.score + dampedSlope * step)
          .round()
          .clamp(0, 380);
      return DailyExposure(
        date: e.date, score: predicted, dayName: e.dayName,
        isToday: e.isToday, isPrediction: true,
      );
    }).toList();
  }

  // ── Monthly: extend 4 weeks, gradual & capped ────────────
  static List<DailyExposure> generateMonthlyPrediction(AnalyticsPeriod p) {
    final lastScore = p.data.last.score;
    final lastDate = p.data.last.date;

    final extended = p.data.map((e) => DailyExposure(
        date: e.date, score: e.score, dayName: e.dayName,
        isToday: e.isToday, isPrediction: false, isSimulated: false
    )).toList();

    // 1. VARIABLE TO CHANGE: The Trend Factor
    // Instead of a flat 3.5, we calculate a tiny daily increase to reach ~10%
    // total growth over 28 days. (e.g., 280 * 0.10 / 28 ≈ 1.0 points per day)
    final double dailyTrendInc = (lastScore * 0.10) / 28;

    for (int i = 1; i <= 28; i++) {
      final date = lastDate.add(Duration(days: i));

      // 2. VARIABLE TO CHANGE: The Zig-Zag Noise
      // This formula creates non-repeating "random-looking" jitters.
      // We use the date and index to create a fluctuating offset between -12 and +12.
      final double zigZag = (((i * 13) + (date.day * 7)) % 25) - 12;

      // 3. APPLY: Base + (Trend * Day) + ZigZag
      final predicted = (lastScore + (dailyTrendInc * i) + zigZag)
          .round()
          .clamp(100, 450); // Keep it within healthy graph bounds

      extended.add(DailyExposure(
        date: date,
        score: predicted,
        dayName: _dayName(date.weekday),
        isPrediction: true,
      ));
    }
    return extended;
  }
  // ── Simulation: marginal contribution algorithm ───────────
  // FIX 3 — Only accepts PREDICTED days; historical passed separately
  // FIX — baseExposureScore comes from weeklyData.averageScore
  static SimulationResult simulate({
    required List<DailyExposure> predictedData,
    required List<Precaution>    selectedPrecautions,
    required double              baseExposureScore,
  }) {
    final eBase = baseExposureScore; // e.g. weeklyData.averageScore

    // Step 2: E_final compounded
    double eFinal = eBase;
    for (final p in selectedPrecautions) {
      eFinal *= (1 - p.reductionCoefficient);
    }

    // Step 3: Marginal contribution per precaution
    final impacts = <String, double>{};
    for (final p in selectedPrecautions) {
      double eWithout = eBase;
      for (final other in selectedPrecautions) {
        if (other.id != p.id) eWithout *= (1 - other.reductionCoefficient);
      }
      impacts[p.id] = eWithout - eFinal;
    }

    // Step 4: Normalize to % ranking
    final totalImpact = impacts.values.fold(0.0, (a, b) => a + b);
    // Work on COPIES so we never mutate the originals passed in
    final ranked = selectedPrecautions.map((p) {
      final copy = Precaution(
        id: p.id, title: p.title, subtitle: p.subtitle,
        icon: p.icon, reductionCoefficient: p.reductionCoefficient,
        isSelected: p.isSelected,
      );
      copy.impactPercent = totalImpact > 0
          ? (impacts[p.id]! / totalImpact) * 100
          : 0;
      return copy;
    }).toList();

    ranked.sort((a, b) =>
        (b.impactPercent ?? 0).compareTo(a.impactPercent ?? 0));
    for (int i = 0; i < ranked.length; i++) {
      ranked[i].rank = i + 1;
    }

    final totalReduction = eBase > 0 ? ((eBase - eFinal) / eBase) : 0.0;

    return SimulationResult(
      baselineExposure: eBase,
      finalExposure: eFinal,
      totalReductionPercent: totalReduction * 100,
      rankedPrecautions: ranked,
    );
  }

  // ── FIX 3 — Simulation only touches prediction days ───────
  // Historical days are returned UNCHANGED with isSimulated=false.
  // Only isPrediction==true days get the reduction applied.
  static List<DailyExposure> applySimulationToChart({
    required List<DailyExposure> predictedData,   // full list incl. history
    required double reductionFactor,              // 0.0 – 1.0
  }) {
    return predictedData.map((e) {
      if (!e.isPrediction) {
        // FIX 3 — Historical data: return completely unchanged
        return DailyExposure(
          date: e.date, score: e.score, dayName: e.dayName,
          isToday: e.isToday, isPrediction: false, isSimulated: false,
        );
      }
      // FIX 5 — Predicted days: apply full reduction gradually
      // Simulate a gradual adoption curve — day 1 gets less reduction,
      // day 28 gets full reduction, making the drop look smooth not vertical.
      final allPredicted = predictedData.where((d) => d.isPrediction).toList();
      final dayIndex     = allPredicted.indexWhere((d) => d.date == e.date);
      final totalDays    = allPredicted.length;
      // Ramp from 20% of reduction on day 1 → 100% by final day
      final ramp         = totalDays > 1
          ? 0.2 + 0.8 * (dayIndex / (totalDays - 1))
          : 1.0;
      final effectiveFactor = reductionFactor * ramp;

      return DailyExposure(
        date: e.date,
        score: (e.score * (1 - effectiveFactor)).round().clamp(0, 500),
        dayName: e.dayName,
        isToday: e.isToday,
        isPrediction: true,
        isSimulated: true,
      );
    }).toList();
  }

  // Improved Slope calculation focusing on the most recent trend
  static double _slope(List<DailyExposure> data) {
    if (data.length < 2) return 0;
    // We weight the recent days more heavily to detect current momentum
    final recent = data.length > 7 ? data.sublist(data.length - 7) : data;
    double totalDiff = 0;
    for (int i = 1; i < recent.length; i++) {
      totalDiff += (recent[i].score - recent[i - 1].score);
    }
    return totalDiff / (recent.length - 1);
  }
  static String _dayName(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][(w - 1).clamp(0, 6)];
}

extension ListTakeLast<T> on List<T> {
  List<T> takeLast(int n) => length <= n ? this : sublist(length - n);
}