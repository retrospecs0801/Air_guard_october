// lib/analytics/widgets/precaution_panel.dart
//
// Replaces simulation_insight_card.dart entirely.
// Shows 7 toggleable precaution cards.
// After simulation: shows ranked impact % and reorders cards.
//
import 'package:flutter/material.dart';
import '../models/analytics_data.dart';

class PrecautionPanel extends StatelessWidget {
  final List<Precaution> precautions;
  final bool isSimulated;
  final ValueChanged<String> onToggle; // passes precaution id

  const PrecautionPanel({
    Key? key,
    required this.precautions,
    required this.isSimulated,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // ── Header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSimulated
                        ? Icons.shield_outlined
                        : Icons.checklist_rounded,
                    size: 18,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSimulated
                            ? 'Impact Ranking'
                            : 'Protection Measures',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      Text(
                        isSimulated
                            ? 'Ranked by marginal contribution'
                            : 'Select to include in simulation',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Selected count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${precautions.where((p) => p.isSelected).length}/${precautions.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 4),

          // ── Precaution cards ──────────────────────────────
          ...precautions.asMap().entries.map((entry) {
            final idx = entry.key;
            final p   = entry.value;
            return _PrecautionTile(
              precaution: p,
              isSimulated: isSimulated,
              isLast: idx == precautions.length - 1,
              onToggle: () => onToggle(p.id),
            );
          }),

          // ── Post-simulation total bar ─────────────────────
          if (isSimulated) _buildTotalBar(),
        ],
      ),
    );
  }

  Widget _buildTotalBar() {
    final selected = precautions.where((p) => p.isSelected).toList();
    if (selected.isEmpty) return const SizedBox.shrink();

    // Recompute total reduction for display
    double eFinal = 1.0;
    for (final p in selected) {
      eFinal *= (1 - p.reductionCoefficient);
    }
    final totalPct = ((1 - eFinal) * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.teal.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_down_rounded,
              color: AppColors.teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Combined protection reduces\ncumulative exposure by',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.teal.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
          Text(
            '$totalPct%',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.teal,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Individual precaution tile
// ─────────────────────────────────────────────────────────
class _PrecautionTile extends StatelessWidget {
  final Precaution precaution;
  final bool isSimulated;
  final bool isLast;
  final VoidCallback onToggle;

  const _PrecautionTile({
    required this.precaution,
    required this.isSimulated,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final p          = precaution;
    final isSelected = p.isSelected;
    final hasRank    = isSimulated && p.impactPercent != null && isSelected;

    return InkWell(
      onTap: onToggle,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 11),
            child: Row(
              children: [
                // ── Rank badge (post-simulation) ──────────
                if (isSimulated && isSelected && p.rank != null)
                  _rankBadge(p.rank!)
                else
                  const SizedBox(width: 24),

                const SizedBox(width: 10),

                // ── Emoji icon ────────────────────────────
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.background
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      p.icon,
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? null : Colors.black26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Title + subtitle ──────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          decoration: isSelected
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      if (isSelected)
                        Text(
                          p.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Right side: impact % or checkbox ──────
                if (hasRank)
                  _impactChip(p.impactPercent!)
                else
                  _checkbox(isSelected),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
                height: 1, indent: 62, color: AppColors.divider),
        ],
      ),
    );
  }

  Widget _rankBadge(int rank) {
    final colors = [
      const Color(0xFFF59E0B), // gold  — rank 1
      const Color(0xFF9CA3AF), // silver — rank 2
      const Color(0xFFB45309), // bronze — rank 3
    ];
    final color = rank <= 3 ? colors[rank - 1] : AppColors.textMuted;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _impactChip(double pct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.teal.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '${pct.toStringAsFixed(1)}%',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.teal,
        ),
      ),
    );
  }

  Widget _checkbox(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? AppColors.navy : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}