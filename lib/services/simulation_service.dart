// lib/services/simulation_service.dart
//
// Pure math layer. No Flutter dependencies.
// All methods are static — no instantiation needed.

import 'dart:math';
import '../models/policy_model.dart';

class SimulationService {
  /// Computes day-by-day AQI values for the policy-applied curve.
  /// Returns a list of [days + 1] values (day 0 through day N).
  ///
  /// Formula: AQI(t) = AQI₀ × e^(-k×t)
  /// where k = kBase × intensityMultiplier
  static List<double> computePolicyCurve({
    required double baseAqi,
    required double kBase,
    required double intensityMultiplier,
    required int days,
  }) {
    final k = kBase * intensityMultiplier;
    return List.generate(
      days + 1,
          (t) => baseAqi * exp(-k * t),
    );
  }

  /// Computes baseline curve — slight natural upward drift without intervention.
  /// Models seasonal accumulation: +0.3 AQI per day, capped at +20%.
  static List<double> computeBaselineCurve({
    required double baseAqi,
    required int days,
  }) {
    return List.generate(
      days + 1,
          (t) {
        final drift = baseAqi + (t * 0.3);
        final cap = baseAqi * 1.20;
        return drift > cap ? cap : drift;
      },
    );
  }

  /// Reduction ratio at the final day. Used to scale the heatmap.
  /// e.g. 0.86 means 14% reduction
  static double computeReductionRatio({
    required double baseAqi,
    required double kBase,
    required double intensityMultiplier,
    required int days,
  }) {
    final k = kBase * intensityMultiplier;
    return exp(-k * days);
  }

  /// Computes percentage AQI reduction at the chosen day.
  static double computeReductionPercent({
    required double baseAqi,
    required double kBase,
    required double intensityMultiplier,
    required int days,
  }) {
    final ratio = computeReductionRatio(
      baseAqi: baseAqi,
      kBase: kBase,
      intensityMultiplier: intensityMultiplier,
      days: days,
    );
    return (1 - ratio) * 100;
  }

  /// Returns average AQI across all stations.
  /// Used as the AQI₀ for the exponential model.
  static double averageAqi(List<double> aqiValues) {
    if (aqiValues.isEmpty) return 150;
    return aqiValues.reduce((a, b) => a + b) / aqiValues.length;
  }

  /// Primary contributor share: what % of the total AQI improvement
  /// came from the dominant affected source.
  /// e.g. Odd-Even: transport share = 35%, impact = 40%
  ///      total reduction = 14%, transport contribution = (35×40/100)/14 = 100%
  /// Clamped to avoid >100% edge cases.
  static int primaryContributorShare({
    required Map<String, double> sourceBreakdown,
    required Map<String, double> sourceImpact,
    required double totalReductionPercent,
  }) {
    if (totalReductionPercent == 0) return 0;

    // Find source with highest individual contribution
    double maxContribution = 0;
    sourceImpact.forEach((source, impact) {
      final share = sourceBreakdown[source] ?? 0;
      final contribution = (share / 100) * (impact / 100) * 100;
      if (contribution > maxContribution) maxContribution = contribution;
    });

    final share = (maxContribution / totalReductionPercent) * 100;
    return share.clamp(0, 100).round();
  }
}