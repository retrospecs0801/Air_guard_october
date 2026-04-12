// lib/map/widgets/route_info_card.dart
import 'package:flutter/material.dart';
import '../models/map_data.dart';

class RouteInfoCard extends StatelessWidget {
  final bool routesVisible;
  final VoidCallback onCompare;
  final VoidCallback onReset;

  const RouteInfoCard({
    Key? key,
    required this.routesVisible,
    required this.onCompare,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: routesVisible ? _expandedCard() : _collapsedCard(),
    );
  }

  // ── Collapsed: just origin/dest + compare button ────────
  Widget _collapsedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _routeSummaryRow(),
          const SizedBox(height: 14),
          _compareButton(),
        ],
      ),
    );
  }

  // ── Expanded: route cards + savings banner + reset ──────
  Widget _expandedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _routeSummaryRow(),
          const SizedBox(height: 14),
          _routeRow(
            route:    MockMapData.defaultRoute,
            isEco:    false,
            isWinner: false,
          ),
          const SizedBox(height: 8),
          _routeRow(
            route:    MockMapData.ecoRoute,
            isEco:    true,
            isWinner: true,
          ),
          const SizedBox(height: 12),
          _savingsBanner(),
          const SizedBox(height: 12),
          _resetButton(),
        ],
      ),
    );
  }

  Widget _routeSummaryRow() {
    return Row(
      children: [
        Container(
          width:  36,
          height: 36,
          decoration: BoxDecoration(
            color:        const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(Icons.navigation_rounded,
              size: 18, color: Color(0xFF0F766E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hazratganj',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              Text('→ Indira Nagar  ·  8.2 km',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500)),
            ],
          ),
        ),
        _aqiLegend(),
      ],
    );
  }

  Widget _aqiLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendDot(const Color(0xFF22C55E), 'Good'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFFF59E0B), 'High'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFFEF4444), '↑High'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 7, height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _routeRow({
    required MapRoute route,
    required bool isEco,
    required bool isWinner,
  }) {
    final bgColor = isEco
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    final borderColor = isEco
        ? const Color(0xFFBBF7D0)
        : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
                color: route.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(route.label,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827))),
                    if (isWinner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:        const Color(0xFF0F766E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('RECOMMENDED',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('Exposure score: ${route.exposureScore}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text('${route.durationMinutes} min',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                ],
              ),
              if (isEco)
                Text('+5 min',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _savingsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        const Color(0xFF0F766E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('40%',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5)),
              Text('less exposure',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8))),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _savingsItem(Icons.air_rounded, 'Breathing air 40% cleaner'),
                const SizedBox(height: 5),
                _savingsItem(Icons.access_time_rounded, 'Only 5 min slower'),
                const SizedBox(height: 5),
                _savingsItem(Icons.trending_down_rounded,
                    'Exposure: 312 → 187'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _savingsItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.85)),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _compareButton() {
    return GestureDetector(
      onTap: onCompare,
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:        const Color(0xFF0F766E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alt_route_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Compare Routes',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _resetButton() {
    return GestureDetector(
      onTap: onReset,
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF374151)),
            SizedBox(width: 6),
            Text('Reset Routes',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}