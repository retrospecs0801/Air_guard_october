// lib/screens/community/policy_simulation_tab.dart

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/policy_data.dart';
import '../../data/aqi_station_data.dart';
import '../../map/models/map_data.dart';
import '../../map/services/aqi_map_service.dart';
import '../../models/policy_model.dart';
import '../../services/simulation_service.dart';
import '../../services/gemini_insight_service.dart';
import '../../widgets/community/policy_picker_row.dart';
import '../../widgets/community/simulation_controls.dart';
import '../../widgets/community/aqi_trend_chart.dart';
import '../../widgets/community/simulated_heatmap_card.dart';
import '../../widgets/community/policy_insight_card.dart';

class PolicySimulationTab extends StatefulWidget {
  const PolicySimulationTab({super.key});

  @override
  State<PolicySimulationTab> createState() => _PolicySimulationTabState();
}

class _PolicySimulationTabState extends State<PolicySimulationTab> {
  PolicyModel? _selectedPolicy;
  int _selectedDays = 30;
  SimulationIntensity _selectedIntensity = SimulationIntensity.medium;

  bool _isLoading = false;
  bool _hasResult = false;

  // Simulation output
  List<double> _baselineCurve = [];
  List<double> _policyCurve = [];
  double _reductionRatio = 1.0;
  InsightResult? _insightResult;

  double _baseAqi = 150; // Derived from real/fallback station data

  Future<void> _runSimulation() async {
    if (_selectedPolicy == null) return;

    setState(() => _isLoading = true);

    // 1. Load AQI baseline
    _baseAqi = await _loadBaseAqi();

    final policy = _selectedPolicy!;
    final k = policy.effectiveK(_selectedIntensity.multiplier);

    // 2. Compute curves
    final baseline = SimulationService.computeBaselineCurve(
      baseAqi: _baseAqi,
      days: _selectedDays,
    );
    final policyCurve = SimulationService.computePolicyCurve(
      baseAqi: _baseAqi,
      kBase: policy.kBase,
      intensityMultiplier: _selectedIntensity.multiplier,
      days: _selectedDays,
    );

    // 3. Compute reduction metrics
    final reductionRatio = SimulationService.computeReductionRatio(
      baseAqi: _baseAqi,
      kBase: policy.kBase,
      intensityMultiplier: _selectedIntensity.multiplier,
      days: _selectedDays,
    );
    final reductionPercent = SimulationService.computeReductionPercent(
      baseAqi: _baseAqi,
      kBase: policy.kBase,
      intensityMultiplier: _selectedIntensity.multiplier,
      days: _selectedDays,
    );
    final finalAqi = _baseAqi * reductionRatio;

    // 4. Contributor share (model-based, not from AI)
    final contributorShare = SimulationService.primaryContributorShare(
      sourceBreakdown: policy.sourceBreakdown,
      sourceImpact: policy.sourceImpact,
      totalReductionPercent: policy.aqiReductionPercent,
    );

    // 5. Get AI narrative (with mock fallback)
    final narrativeResult = await GeminiInsightService.generateNarrative(
      policy: policy,
      reductionPercent: reductionPercent,
      days: _selectedDays,
      intensity: _selectedIntensity,
      baseAqi: _baseAqi,
      finalAqi: finalAqi,
    );

    final insight = InsightResult(
      reductionPercent: reductionPercent,
      primaryContributor: policy.primaryContributor,
      contributionShare: contributorShare,
      secondaryEffect: policy.secondaryEffect,
      aiNarrative: narrativeResult.narrative,
      isAiGenerated: narrativeResult.isAi,
      sourceBreakdown: Map<String, double>.from(policy.sourceBreakdown),
      finalAqi: finalAqi,
      baselineAqi: _baseAqi,
    );

    if (mounted) {
      setState(() {
        _baselineCurve = baseline;
        _policyCurve = policyCurve;
        _reductionRatio = reductionRatio;
        _insightResult = insight;
        _isLoading = false;
        _hasResult = true;
      });
    }
  }

  /// Loads average AQI from SharedPrefs cache, falls back to hardcoded data.
  Future<double> _loadBaseAqi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = AqiMapService.fromCache(prefs);
      if (cached != null && cached.isNotEmpty) {
        final aqiValues = cached.map((s) => s.aqi).toList();
        return SimulationService.averageAqi(aqiValues);
      }
    } catch (_) {}

    // Fallback to hardcoded
    final aqiValues =
    AqiStationData.lucknowStations.map((s) => s.aqi).toList();
    return SimulationService.averageAqi(aqiValues);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ── Section header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Policy Simulation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Model the AQI impact of real pollution control policies over time.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Policy picker ──
          _SectionLabel(label: 'Select Policy'),
          const SizedBox(height: 10),
          PolicyPickerRow(
            selectedId: _selectedPolicy?.id,
            onSelected: (policy) {
              setState(() {
                _selectedPolicy = policy;
                _hasResult = false;
              });
            },
          ),
          const SizedBox(height: 20),

          // ── Controls ──
          _SectionLabel(label: 'Configure'),
          const SizedBox(height: 10),
          SimulationControls(
            selectedDays: _selectedDays,
            selectedIntensity: _selectedIntensity,
            isLoading: _isLoading,
            hasPolicy: _selectedPolicy != null,
            onDaysChanged: (days) {
              setState(() {
                _selectedDays = days;
                _hasResult = false;
              });
            },
            onIntensityChanged: (intensity) {
              setState(() {
                _selectedIntensity = intensity;
                _hasResult = false;
              });
            },
            onSimulate: _runSimulation,
          ),

          // ── Results (animated in) ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 350),
            crossFadeState: _hasResult
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _hasResult
                ? _ResultsSection(
              baselineCurve: _baselineCurve,
              policyCurve: _policyCurve,
              reductionRatio: _reductionRatio,
              insightResult: _insightResult!,
              policy: _selectedPolicy!,
              days: _selectedDays,
            )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final List<double> baselineCurve;
  final List<double> policyCurve;
  final double reductionRatio;
  final InsightResult insightResult;
  final PolicyModel policy;
  final int days;

  const _ResultsSection({
    required this.baselineCurve,
    required this.policyCurve,
    required this.reductionRatio,
    required this.insightResult,
    required this.policy,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _SectionLabel(label: 'Simulation Results'),
        const SizedBox(height: 12),
        AqiTrendChart(
          baselineCurve: baselineCurve,
          policyCurve: policyCurve,
          days: days,
          policyName: policy.name,
        ),
        const SizedBox(height: 14),
        SimulatedHeatmapCard(reductionRatio: reductionRatio),
        const SizedBox(height: 14),
        PolicyInsightCard(result: insightResult, policy: policy),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}