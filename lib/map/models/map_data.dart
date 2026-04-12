// lib/map/models/map_data.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────────────────
// AQI Station Point — real data model
// ─────────────────────────────────────────────────────────
class AqiStationPoint {
  final LatLng position;
  final String stationName;
  final double aqi;
  final double pm25;
  final double no2;
  final double pm10;

  const AqiStationPoint({
    required this.position,
    required this.stationName,
    required this.aqi,
    required this.pm25,
    required this.no2,
    required this.pm10,
  });

  Map<String, dynamic> toJson() => {
    'lat': position.latitude,
    'lng': position.longitude,
    'name': stationName,
    'aqi': aqi,
    'pm25': pm25,
    'no2': no2,
    'pm10': pm10,
  };

  factory AqiStationPoint.fromCacheJson(Map<String, dynamic> j) =>
      AqiStationPoint(
        position: LatLng(
          (j['lat'] as num).toDouble(),
          (j['lng'] as num).toDouble(),
        ),
        stationName: j['name'] ?? '',
        aqi: (j['aqi'] as num).toDouble(),
        pm25: (j['pm25'] as num).toDouble(),
        no2: (j['no2'] as num).toDouble(),
        pm10: (j['pm10'] as num).toDouble(),
      );

  Color get aqiColor => _aqiColor(aqi);

  static Color _aqiColor(double v) {
    if (v <= 50) return const Color(0xFF22C55E);
    if (v <= 100) return const Color(0xFFF59E0B);
    if (v <= 150) return const Color(0xFFEF4444);
    if (v <= 200) return const Color(0xFF991B1B);
    return const Color(0xFF7C3AED);
  }

  static Color colorForValue(double v, String pollutant) {
    switch (pollutant) {
      case 'pm25':
        if (v <= 12) return const Color(0xFF22C55E);
        if (v <= 35) return const Color(0xFFF59E0B);
        if (v <= 55) return const Color(0xFFEF4444);
        if (v <= 150) return const Color(0xFF991B1B);
        return const Color(0xFF7C3AED);
      case 'no2':
        if (v <= 40) return const Color(0xFF22C55E);
        if (v <= 80) return const Color(0xFFF59E0B);
        if (v <= 180) return const Color(0xFFEF4444);
        if (v <= 280) return const Color(0xFF991B1B);
        return const Color(0xFF7C3AED);
      case 'pm10':
        if (v <= 54) return const Color(0xFF22C55E);
        if (v <= 154) return const Color(0xFFF59E0B);
        if (v <= 254) return const Color(0xFFEF4444);
        if (v <= 354) return const Color(0xFF991B1B);
        return const Color(0xFF7C3AED);
      default:
        return _aqiColor(v);
    }
  }

  double valueFor(String pollutant) {
    switch (pollutant) {
      case 'pm25': return pm25;
      case 'no2':  return no2;
      case 'pm10': return pm10;
      default:     return aqi;
    }
  }
}

// ─────────────────────────────────────────────────────────
// Mock AQI zones — based on real fetched station data
// Used in demo mode for eco route demonstration
// ─────────────────────────────────────────────────────────
class AqiZone {
  final LatLng center;
  final double radius;
  final double aqi;
  final String label;

  const AqiZone({
    required this.center,
    required this.radius,
    required this.aqi,
    required this.label,
  });

  Color get color => AqiStationPoint._aqiColor(aqi);
}

// ─────────────────────────────────────────────────────────
// Route model
// ─────────────────────────────────────────────────────────
class MapRoute {
  final List<LatLng> points;
  final String label;
  final Color color;
  final int durationMinutes;
  final int exposureScore;
  final double exposureReductionPercent;

  const MapRoute({
    required this.points,
    required this.label,
    required this.color,
    required this.durationMinutes,
    required this.exposureScore,
    this.exposureReductionPercent = 0,
  });
}

// ─────────────────────────────────────────────────────────
// Pollutant chip definition
// ─────────────────────────────────────────────────────────
class PollutantOption {
  final String label;
  final String key;
  final String unit;
  const PollutantOption(this.label, this.key, this.unit);
}

const kPollutants = [
  PollutantOption('AQI',   'aqi',  ''),
  PollutantOption('PM2.5', 'pm25', 'µg/m³'),
  PollutantOption('NO₂',   'no2',  'µg/m³'),
  PollutantOption('PM10',  'pm10', 'µg/m³'),
];

// ─────────────────────────────────────────────────────────
// All map data
// ─────────────────────────────────────────────────────────
class MockMapData {
  static const LatLng mapCenter   = LatLng(26.8600, 80.9600);
  static const LatLng origin      = LatLng(26.8467, 80.9462); // Hazratganj
  static const LatLng destination = LatLng(26.8742, 80.9936); // Indira Nagar

  // ── Real station data fetched 12 Apr 2026 ─────────────
  // Used as fallback when API is unavailable
  static const List<AqiStationPoint> fallbackStations = [
    AqiStationPoint(
      position:    LatLng(26.83399, 80.89173),
      stationName: 'Talkatora',
      aqi:  161,
      pm25: 97,
      no2:  48,
      pm10: 129,
    ),
    AqiStationPoint(
      position:    LatLng(26.86812, 81.00511),
      stationName: 'Gomti Nagar',
      aqi:  156,
      pm25: 94,
      no2:  47,
      pm10: 125,
    ),
    AqiStationPoint(
      position:    LatLng(26.88210, 80.93027),
      stationName: 'Central School',
      aqi:  154,
      pm25: 92,
      no2:  46,
      pm10: 123,
    ),
    AqiStationPoint(
      position:    LatLng(26.84588, 80.93655),
      stationName: 'Lalbagh',
      aqi:  153,
      pm25: 92,
      no2:  46,
      pm10: 122,
    ),
    AqiStationPoint(
      position:    LatLng(26.90723, 80.98579),
      stationName: 'Kukrail',
      aqi:  151,
      pm25: 91,
      no2:  45,
      pm10: 121,
    ),
    AqiStationPoint(
      position:    LatLng(26.76643, 80.92729),
      stationName: 'Ambedkar University',
      aqi:  109,
      pm25: 65,
      no2:  33,
      pm10: 87,
    ),
  ];

  // ── Demo mock zones (for eco route demo) ──────────────
  // Positioned to make eco route visually pass through cleaner zones
  static const List<AqiZone> aqiZones = [
    AqiZone(center: LatLng(26.8527, 80.9575), radius: 900, aqi: 185, label: 'Charbagh'),
    AqiZone(center: LatLng(26.8572, 80.9661), radius: 800, aqi: 172, label: 'Aminabad'),
    AqiZone(center: LatLng(26.8600, 80.9700), radius: 750, aqi: 160, label: 'Alambagh'),
    AqiZone(center: LatLng(26.8628, 80.9763), radius: 700, aqi: 145, label: 'Viram Khand'),
    AqiZone(center: LatLng(26.8688, 80.9530), radius: 800, aqi: 72,  label: 'Nishatganj'),
    AqiZone(center: LatLng(26.8600, 80.9435), radius: 900, aqi: 58,  label: 'Gomti Riverfront'),
    AqiZone(center: LatLng(26.8720, 80.9625), radius: 700, aqi: 85,  label: 'Sector 14'),
    AqiZone(center: LatLng(26.8700, 80.9880), radius: 650, aqi: 118, label: 'Gomti Nagar'),
  ];

  // ── Default route — main roads through congested centre ──
  // Traces: Hazratganj → Vidhan Sabha Marg → Charbagh → MG Marg → Indira Nagar
  static final MapRoute defaultRoute = MapRoute(
    label: 'Default Route',
    color: const Color(0xFFEF4444),
    durationMinutes: 18,
    exposureScore: 312,
    points: const [
      LatLng(26.8467, 80.9462), // Hazratganj clock tower
      LatLng(26.8475, 80.9478), // Vidhan Sabha Marg start
      LatLng(26.8490, 80.9495), // Novelty cinema crossing
      LatLng(26.8505, 80.9522), // Hardinge bridge road
      LatLng(26.8520, 80.9553), // Charbagh approach
      LatLng(26.8530, 80.9575), // Charbagh station
      LatLng(26.8538, 80.9608), // Station Rd east
      LatLng(26.8548, 80.9638), // Aminabad crossing
      LatLng(26.8560, 80.9665), // MG Marg
      LatLng(26.8578, 80.9695), // Kapoorthala crossing
      LatLng(26.8600, 80.9720), // Lohia Path
      LatLng(26.8622, 80.9758), // Viram Khand 1
      LatLng(26.8648, 80.9808), // Viram Khand 2
      LatLng(26.8672, 80.9858), // Gomti Nagar main
      LatLng(26.8700, 80.9896), // Shaheed Path junction
      LatLng(26.8720, 80.9918), // Indira Nagar approach
      LatLng(26.8742, 80.9936), // Indira Nagar
    ],
  );

  // ── Eco route — river road then north corridors ────────
  // Traces: Hazratganj → Butler Palace → Gomti Riverfront → Nishatganj → Sector 14 → Indira Nagar
  static final MapRoute ecoRoute = MapRoute(
    label: 'Eco Route',
    color: const Color(0xFF0F766E),
    durationMinutes: 23,
    exposureScore: 187,
    exposureReductionPercent: 40,
    points: const [
      LatLng(26.8467, 80.9462), // Hazratganj
      LatLng(26.8478, 80.9448), // Butler Palace Rd west
      LatLng(26.8495, 80.9432), // Rana Pratap Marg
      LatLng(26.8520, 80.9418), // River road approach
      LatLng(26.8548, 80.9422), // Gomti riverfront south
      LatLng(26.8580, 80.9430), // Riverfront park
      LatLng(26.8615, 80.9440), // Riverfront north
      LatLng(26.8648, 80.9458), // Nishatganj bridge south
      LatLng(26.8672, 80.9478), // Nishatganj
      LatLng(26.8690, 80.9510), // Sector 9 road
      LatLng(26.8705, 80.9558), // Sector 11
      LatLng(26.8718, 80.9615), // Sector 14 crossing
      LatLng(26.8728, 80.9682), // Sector 14 east
      LatLng(26.8735, 80.9758), // Viram Khand 3
      LatLng(26.8738, 80.9840), // Indira Nagar west
      LatLng(26.8742, 80.9936), // Indira Nagar
    ],
  );
}