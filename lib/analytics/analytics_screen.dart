// lib/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'models/analytics_data.dart';
import 'services/analytics_insight_service.dart';
import 'widgets/stats_cards.dart';
import 'widgets/predict_chart.dart';
import 'widgets/predict_action_buttons.dart';
import 'widgets/precaution_panel.dart';
import 'widgets/comparison_card.dart';
import 'widgets/insight_skeleton.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {

  // ── Raw period data ───────────────────────────────────────
  late AnalyticsPeriod weeklyData;
  late AnalyticsPeriod monthlyData;

  // ── Chart display data ────────────────────────────────────
  late List<DailyExposure> _weeklyChartData;
  late List<DailyExposure> _monthlyChartData;

  // ── Predict / Simulate state ──────────────────────────────
  bool _weeklyPredicting  = false;
  bool _weeklySimulating  = false;
  bool _monthlyPredicting = false;
  bool _monthlySimulating = false;

  // ── Precautions — shared between week & month tabs ───────
  late List<Precaution> _precautions;
  SimulationResult? _weeklyResult;
  SimulationResult? _monthlyResult;

  // ── AI insight (kept for future use, hidden from UI) ─────
  bool _isLoadingWeeklyInsight  = false;
  bool _isLoadingMonthlyInsight = false;

  // ── Inner tab controller ──────────────────────────────────
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    weeklyData        = MockAnalyticsData.getWeeklyData();
    monthlyData       = MockAnalyticsData.getMonthlyData();
    _weeklyChartData  = weeklyData.data;
    _monthlyChartData = monthlyData.data;
    _precautions      = PrecautionRegistry.defaults(); // all selected
  }

  // ── Precaution toggle ─────────────────────────────────────
  void _togglePrecaution(String id) {
    setState(() {
      final idx = _precautions.indexWhere((p) => p.id == id);
      if (idx == -1) return;
      _precautions[idx].isSelected = !_precautions[idx].isSelected;

      // Clear simulation results so user reruns
      if (_weeklySimulating || _monthlySimulating) {
        _clearSimulation();
      }
    });
  }

  void _clearSimulation() {
    _weeklySimulating  = false;
    _monthlySimulating = false;
    _weeklyResult      = null;
    _monthlyResult     = null;
    // Reset chart to predicted state if predicting
    if (_weeklyPredicting) {
      _weeklyChartData = PredictionEngine.generateWeeklyPrediction(weeklyData);
    }
    if (_monthlyPredicting) {
      _monthlyChartData = PredictionEngine.generateMonthlyPrediction(monthlyData);
    }
    // Clear rankings on precautions
    for (final p in _precautions) {
      p.impactPercent = null;
      p.rank = null;
    }
  }

  List<Precaution> get _selectedPrecautions =>
      _precautions.where((p) => p.isSelected).toList();

  // ── Weekly handlers ───────────────────────────────────────
  void _toggleWeeklyPredict() {
    setState(() {
      if (_weeklyPredicting) {
        _weeklyPredicting = false;
        _weeklySimulating = false;
        _weeklyResult     = null;
        _weeklyChartData  = weeklyData.data;
        _clearRanks();
      } else {
        _weeklyPredicting = true;
        _weeklySimulating = false;
        _weeklyChartData  = PredictionEngine.generateWeeklyPrediction(weeklyData);
      }
    });
  }

  void _toggleWeeklySimulate() {
    if (!_weeklyPredicting || _selectedPrecautions.isEmpty) return;
    setState(() {
      if (_weeklySimulating) {
        _weeklySimulating = false;
        _weeklyResult     = null;
        _weeklyChartData  = PredictionEngine.generateWeeklyPrediction(weeklyData);
        _clearRanks();
      } else {
        _weeklySimulating = true;
        final predicted   = PredictionEngine.generateWeeklyPrediction(weeklyData);

        // Run marginal contribution simulation
        // baseExposureScore = weekly avg (not live session score which starts at 0)
        _weeklyResult = PredictionEngine.simulate(
          predictedData: predicted,
          selectedPrecautions: _selectedPrecautions,
          baseExposureScore: weeklyData.averageScore,
        );

        // Apply reduction to chart
        _weeklyChartData = PredictionEngine.applySimulationToChart(
          predictedData: predicted,
          reductionFactor: _weeklyResult!.totalReductionPercent / 100,
        );

        // Update precaution list with ranks (reorder)
        _applyRanks(_weeklyResult!.rankedPrecautions);
      }
    });
  }

  // ── Monthly handlers ──────────────────────────────────────
  void _toggleMonthlyPredict() {
    setState(() {
      if (_monthlyPredicting) {
        _monthlyPredicting = false;
        _monthlySimulating = false;
        _monthlyResult     = null;
        _monthlyChartData  = monthlyData.data;
        _clearRanks();
      } else {
        _monthlyPredicting = true;
        _monthlySimulating = false;
        _monthlyChartData  = PredictionEngine.generateMonthlyPrediction(monthlyData);
      }
    });
  }

  void _toggleMonthlySimulate() {
    if (!_monthlyPredicting || _selectedPrecautions.isEmpty) return;
    setState(() {
      if (_monthlySimulating) {
        _monthlySimulating = false;
        _monthlyResult     = null;
        _monthlyChartData  = PredictionEngine.generateMonthlyPrediction(monthlyData);
        _clearRanks();
      } else {
        _monthlySimulating = true;
        final predicted    = PredictionEngine.generateMonthlyPrediction(monthlyData);

        _monthlyResult = PredictionEngine.simulate(
          predictedData: predicted,
          selectedPrecautions: _selectedPrecautions,
          baseExposureScore: monthlyData.averageScore,
        );

        _monthlyChartData = PredictionEngine.applySimulationToChart(
          predictedData: predicted,
          reductionFactor: _monthlyResult!.totalReductionPercent / 100,
        );

        _applyRanks(_monthlyResult!.rankedPrecautions);
      }
    });
  }

  void _applyRanks(List<Precaution> ranked) {
    // Write rank + impactPercent back onto _precautions, then reorder
    for (final r in ranked) {
      final idx = _precautions.indexWhere((p) => p.id == r.id);
      if (idx != -1) {
        _precautions[idx].impactPercent = r.impactPercent;
        _precautions[idx].rank          = r.rank;
      }
    }
    // Sort selected by rank, unselected go to bottom
    _precautions.sort((a, b) {
      if (a.isSelected && b.isSelected) {
        return (a.rank ?? 99).compareTo(b.rank ?? 99);
      }
      if (a.isSelected) return -1;
      return 1;
    });
  }

  void _clearRanks() {
    for (final p in _precautions) {
      p.impactPercent = null;
      p.rank          = null;
    }
    // Reset to default order
    _precautions = PrecautionRegistry.defaults().map((def) {
      final existing = _precautions.firstWhere(
              (p) => p.id == def.id, orElse: () => def);
      def.isSelected = existing.isSelected;
      return def;
    }).toList();
  }

  ChartMode get _weeklyMode {
    if (_weeklySimulating)  return ChartMode.simulated;
    if (_weeklyPredicting)  return ChartMode.predicted;
    return ChartMode.actual;
  }

  ChartMode get _monthlyMode {
    if (_monthlySimulating) return ChartMode.simulated;
    if (_monthlyPredicting) return ChartMode.predicted;
    return ChartMode.actual;
  }

  bool get _isSimulated => _weeklySimulating || _monthlySimulating;

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Week / Month inner tabs ───────────────────────
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.navy,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.navy,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.borderLight,
            labelPadding: const EdgeInsets.symmetric(vertical: 10),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'This Week'),
              Tab(text: 'This Month'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTab(isWeekly: true),
              _buildTab(isWeekly: false),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Shared tab builder (week and month are identical layout)
  // ─────────────────────────────────────────────────────────
  Widget _buildTab({required bool isWeekly}) {
    final isPredicting = isWeekly ? _weeklyPredicting : _monthlyPredicting;
    final isSimulating = isWeekly ? _weeklySimulating : _monthlySimulating;
    final chartData    = isWeekly ? _weeklyChartData  : _monthlyChartData;
    final periodData   = isWeekly ? weeklyData         : monthlyData;
    final chartMode    = isWeekly ? _weeklyMode         : _monthlyMode;
    final result       = isWeekly ? _weeklyResult       : _monthlyResult;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Stats row ────────────────────────────────
            StatsCards(data: periodData, period: isWeekly ? 'week' : 'month'),
            const SizedBox(height: 12),

            // ── Comparison card ───────────────────────────
            ComparisonCard(
              data: periodData,
              currentPeriod: isWeekly ? 'This Week' : 'This Month',
              previousPeriod: isWeekly ? 'Last Week' : 'Last Month',
            ),
            const SizedBox(height: 12),

            // ── Predict / Simulate buttons ────────────────
            PredictActionButtons(
              isPredicting: isPredicting,
              isSimulating: isSimulating,
              canSimulate:  _selectedPrecautions.isNotEmpty,
              onPredict:    isWeekly
                  ? _toggleWeeklyPredict
                  : _toggleMonthlyPredict,
              onSimulate:   isWeekly
                  ? _toggleWeeklySimulate
                  : _toggleMonthlySimulate,
            ),
            const SizedBox(height: 12),

            // ── Chart ─────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isWeekly
                  ? PredictWeeklyChart(
                key: ValueKey('w-${chartMode.name}-${chartData.length}'),
                data: chartData,
                mode: chartMode,
              )
                  : PredictMonthlyChart(
                key: ValueKey('m-${chartMode.name}-${chartData.length}'),
                data: chartData,
                mode: chartMode,
              ),
            ),
            const SizedBox(height: 12),

            // ── Simulation summary banner ─────────────────
            if (isSimulating && result != null)
              _buildSimulationSummaryBanner(result),

            if (isSimulating && result != null)
              const SizedBox(height: 12),

            // ── Precaution panel (always visible) ─────────
            PrecautionPanel(
              precautions: _precautions,
              isSimulated: isSimulating,
              onToggle: _togglePrecaution,
            ),
            const SizedBox(height: 12),

            // ── Disclaimer ────────────────────────────────
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Simulation summary banner
  // ─────────────────────────────────────────────────────────
  Widget _buildSimulationSummaryBanner(SimulationResult result) {
    final pct = result.totalReductionPercent.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Big number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const Text(
                'less exposure',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 44, color: Colors.white24),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedPrecautions.length} measures active',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Exposure: ${result.baselineExposure.round()} → ${result.finalExposure.round()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tap any measure to deselect & rerun',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Disclaimer
  // ─────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Simulation uses EPA/WHO mitigation coefficients. '
                  'Impact ranking uses marginal contribution analysis — '
                  'each measure\'s rank reflects its isolated effect given your full selection.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}