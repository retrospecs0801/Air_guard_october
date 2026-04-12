// lib/widgets/community/simulated_heatmap_card.dart
//
// Renders the same Lucknow AQI heatmap as the Map tab,
// but with AQI values multiplied by reductionRatio (e.g. 0.86).
// Uses AqiStationPoint.colorForValue() for consistent color logic.
// Read-only — no route overlay, no interactions.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../map/models/map_data.dart'; // AqiStationPoint lives here
import '../../data/aqi_station_data.dart';

class SimulatedHeatmapCard extends StatelessWidget {
  /// Value between 0 and 1. e.g. 0.86 = 14% reduction
  final double reductionRatio;

  const SimulatedHeatmapCard({
    super.key,
    required this.reductionRatio,
  });

  List<AqiStationPoint> _buildReducedStations() {
    return AqiStationData.lucknowStations.map((s) {
      return AqiStationPoint(
        position: LatLng(s.lat, s.lng),
        stationName: s.name,
        aqi: s.aqi * reductionRatio,
        pm25: s.pm25 * reductionRatio,
        // no2 and pm10 not in fallback data — scale proportionally from aqi
        no2: (s.aqi * 0.4) * reductionRatio,
        pm10: (s.aqi * 0.6) * reductionRatio,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stations = _buildReducedStations();

    // Lucknow center
    const center = LatLng(26.8467, 80.9462);

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Text(
                    'Simulated AQI Map',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'After Policy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map
            SizedBox(
              height: 240,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: center,
                  initialZoom: 12.0,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.none, // read-only
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.airguard.app',
                  ),
                  CircleLayer(
                    circles: stations.map((station) {
                      final color = AqiStationPoint.colorForValue(
                        station.aqi,
                        'aqi',
                      );
                      return CircleMarker(
                        point: station.position,
                        radius: 800,
                        color: color.withOpacity(0.28),
                        borderColor: color.withOpacity(0.70),
                        borderStrokeWidth: 1.5,
                        useRadiusInMeter: true,
                      );
                    }).toList(),
                  ),
                  MarkerLayer(
                    markers: stations.map((station) {
                      return Marker(
                        point: station.position,
                        width: 60,
                        height: 28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            station.aqi.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AqiStationPoint.colorForValue(
                                station.aqi,
                                'aqi',
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Bottom legend strip
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  _MapLegendDot(
                      color: const Color(0xFF22C55E), label: 'Good'),
                  const SizedBox(width: 10),
                  _MapLegendDot(
                      color: const Color(0xFFF59E0B), label: 'Moderate'),
                  const SizedBox(width: 10),
                  _MapLegendDot(
                      color: const Color(0xFFEF4444), label: 'Poor'),
                  const Spacer(),
                  Text(
                    'Lucknow, UP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MapLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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