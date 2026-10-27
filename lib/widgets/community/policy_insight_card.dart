// lib/widgets/community/policy_insight_card.dart

import 'package:flutter/material.dart';

import '../../../models/policy_model.dart';

class PolicyInsightCard extends StatelessWidget {
  final InsightResult result;
  final PolicyModel policy;

  const PolicyInsightCard({
    super.key,
    required this.result,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          // ── Top metric strip ──
          _TopMetricStrip(result: result),
          Divider(height: 1, color: Colors.grey.shade100),

          // ── Source breakdown bar ──
          _SourceBreakdownSection(result: result),
          Divider(height: 1, color: Colors.grey.shade100),

          // ── Structured insight rows ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _InsightRow(
                  icon: Icons.arrow_downward,
                  iconColor: const Color(0xFF0F766E),
                  label: 'Primary Driver',
                  value:
                  '${result.primaryContributor} (${result.contributionShare}% of gain)',
                ),
                const SizedBox(height: 10),
                _InsightRow(
                  icon: Icons.science,
                  iconColor: const Color(0xFF6366F1),
                  label: 'Secondary Effect',
                  value: result.secondaryEffect,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),

          // ── AI Narrative ──
          _NarrativeSection(result: result),
        ],
      ),
    );
  }
}

class _TopMetricStrip extends StatelessWidget {
  final InsightResult result;
  const _TopMetricStrip({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = result.reductionPercent;
    final metricColor = pct >= 20
        ? const Color(0xFF22C55E)
        : pct >= 10
        ? const Color(0xFFF59E0B)
        : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          // Big reduction number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AQI Reduction',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '↓ ${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: metricColor,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Before / After AQI
          _AqiBeforeAfter(
            before: result.baselineAqi,
            after: result.finalAqi,
          ),
        ],
      ),
    );
  }
}

class _AqiBeforeAfter extends StatelessWidget {
  final double before;
  final double after;
  const _AqiBeforeAfter({required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _AqiValue(label: 'Now', value: before.toInt(), isAfter: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              size: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          _AqiValue(label: 'After', value: after.toInt(), isAfter: true),
        ],
      ),
    );
  }
}

class _AqiValue extends StatelessWidget {
  final String label;
  final int value;
  final bool isAfter;
  const _AqiValue(
      {required this.label, required this.value, required this.isAfter});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isAfter
                ? const Color(0xFF0F766E)
                : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _SourceBreakdownSection extends StatelessWidget {
  final InsightResult result;
  const _SourceBreakdownSection({required this.result});

  static const Map<String, Color> _sourceColors = {
    'transport': Color(0xFFEF4444),
    'industry': Color(0xFF6366F1),
    'dust': Color(0xFF78716C),
    'others': Color(0xFF9CA3AF),
  };

  static const Map<String, String> _sourceLabels = {
    'transport': 'Transport',
    'industry': 'Industry',
    'dust': 'Dust',
    'others': 'Others',
  };

  @override
  Widget build(BuildContext context) {
    final breakdown = result.sourceBreakdown;
    final total = breakdown.values.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emission Sources',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: breakdown.entries.map((e) {
                  final fraction = total > 0 ? e.value / total : 0.0;
                  return Flexible(
                    flex: (fraction * 1000).round(),
                    child: Container(
                      color: _sourceColors[e.key] ?? Colors.grey,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: breakdown.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _sourceColors[e.key] ?? Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_sourceLabels[e.key] ?? e.key} ${e.value.toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 13, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NarrativeSection extends StatelessWidget {
  final InsightResult result;
  const _NarrativeSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isAiGenerated
                    ? Icons.auto_awesome
                    : Icons.info_outline,
                size: 12,
                color: result.isAiGenerated
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 5),
              Text(
                result.isAiGenerated ? 'AI Analysis' : 'Estimated Analysis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: result.isAiGenerated
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.aiNarrative,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}