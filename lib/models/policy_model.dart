// lib/models/policy_model.dart

import 'package:flutter/material.dart';

class PolicyModel {
  final String id;
  final String name;
  final String shortDescription;
  final IconData icon;
  final double kBase; // exponential decay constant
  final Map<String, double> sourceBreakdown; // % each source contributes to AQI
  final Map<String, double> sourceImpact; // % reduction policy applies to each source
  final String primaryContributor;
  final String secondaryEffect;
  final String affectedSourceTag; // e.g. "Traffic", "Industry"
  final Color tagColor;

  const PolicyModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.icon,
    required this.kBase,
    required this.sourceBreakdown,
    required this.sourceImpact,
    required this.primaryContributor,
    required this.secondaryEffect,
    required this.affectedSourceTag,
    required this.tagColor,
  });

  /// Computes total AQI reduction % from source breakdown × source impact
  double get aqiReductionPercent {
    double total = 0;
    sourceImpact.forEach((source, impact) {
      final share = sourceBreakdown[source] ?? 0;
      total += (share / 100) * (impact / 100) * 100;
    });
    return total;
  }

  /// Effective k value after applying intensity multiplier
  double effectiveK(double intensityMultiplier) => kBase * intensityMultiplier;
}

class InsightResult {
  final double reductionPercent;
  final String primaryContributor;
  final int contributionShare; // % of total improvement from primary source
  final String secondaryEffect;
  final String aiNarrative;
  final bool isAiGenerated;
  final Map<String, double> sourceBreakdown;
  final double finalAqi;
  final double baselineAqi;

  const InsightResult({
    required this.reductionPercent,
    required this.primaryContributor,
    required this.contributionShare,
    required this.secondaryEffect,
    required this.aiNarrative,
    required this.isAiGenerated,
    required this.sourceBreakdown,
    required this.finalAqi,
    required this.baselineAqi,
  });
}

enum SimulationIntensity {
  low,
  medium,
  high;

  double get multiplier {
    switch (this) {
      case SimulationIntensity.low:
        return 0.7;
      case SimulationIntensity.medium:
        return 1.0;
      case SimulationIntensity.high:
        return 1.3;
    }
  }

  String get label {
    switch (this) {
      case SimulationIntensity.low:
        return 'Low';
      case SimulationIntensity.medium:
        return 'Medium';
      case SimulationIntensity.high:
        return 'High';
    }
  }
}