// lib/map/widgets/aqi_heat_layer.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_data.dart';

/// Renders a blurred blob heatmap layer with AQI number chips.
/// Supports both real [stations] and mock [mockZones] modes.
class AqiHeatLayer extends StatelessWidget {
  final List<AqiStationPoint>? stations;
  final List<AqiZone>?         mockZones;
  final String                 selectedPollutant;

  const AqiHeatLayer({
    Key? key,
    this.stations,
    this.mockZones,
    this.selectedPollutant = 'aqi',
  }) : super(key: key);

  // ── EPA standard AQI → color ──────────────────────────────────────────────
  static Color colorForAqi(double aqi) {
    if (aqi <= 50)  return const Color(0xFF2ECC71); // Good — green
    if (aqi <= 100) return const Color(0xFFF1C40F); // Moderate — yellow
    if (aqi <= 150) return const Color(0xFFE67E22); // USG — orange
    if (aqi <= 200) return const Color(0xFFE74C3C); // Unhealthy — red
    if (aqi <= 300) return const Color(0xFF8E44AD); // Very Unhealthy — purple
    return const Color(0xFF7B241C);                 // Hazardous — maroon
  }

  static String labelForAqi(double aqi) {
    if (aqi <= 50)  return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Bad';
    return 'Hazardous';
  }

  static Color _colorForStation(AqiStationPoint s, String pollutant) {
    if (pollutant == 'aqi') return colorForAqi(s.aqi);
    return AqiStationPoint.colorForValue(s.valueFor(pollutant), pollutant);
  }

  @override
  Widget build(BuildContext context) {
    if (mockZones != null && mockZones!.isNotEmpty) return _mockLayer(context);
    if (stations  != null && stations!.isNotEmpty)  return _realLayer(context);
    return const SizedBox.shrink();
  }

  Widget _mockLayer(BuildContext context) {
    return MobileLayerTransformer(
      child: CustomPaint(
        painter: _MockBlobPainter(
          zones:  mockZones!,
          camera: MapCamera.of(context),
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _realLayer(BuildContext context) {
    return Stack(
      children: [
        MobileLayerTransformer(
          child: CustomPaint(
            painter: _RealBlobPainter(
              stations:  stations!,
              pollutant: selectedPollutant,
              camera:    MapCamera.of(context),
            ),
            size: Size.infinite,
          ),
        ),
        MarkerLayer(
          markers: stations!.map((s) {
            final value = s.valueFor(selectedPollutant);
            final color = _colorForStation(s, selectedPollutant);
            return Marker(
              point:  s.position,
              width:  60,
              height: 46,
              child:  _AqiChip(
                value:     value,
                pollutant: selectedPollutant,
                color:     color,
                label:     selectedPollutant == 'aqi'
                    ? labelForAqi(s.aqi)
                    : selectedPollutant.toUpperCase(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Real station blob painter ───────────────────────────────────────────────

class _RealBlobPainter extends CustomPainter {
  final List<AqiStationPoint> stations;
  final String                pollutant;
  final MapCamera             camera;

  const _RealBlobPainter({
    required this.stations,
    required this.pollutant,
    required this.camera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stations) {
      final color  = pollutant == 'aqi'
          ? AqiHeatLayer.colorForAqi(s.aqi)
          : AqiStationPoint.colorForValue(s.valueFor(pollutant), pollutant);
      final pt     = camera.latLngToScreenPoint(s.position);
      final offset = Offset(pt.x.toDouble(), pt.y.toDouble());

      final double severity = (s.aqi / 400).clamp(0.0, 1.0);
      final double radius   = 36 + severity * 20; // 36–56 px

      // Outer atmospheric glow
      canvas.drawCircle(
        offset,
        radius * 2.4,
        Paint()
          ..shader = ui.Gradient.radial(
            offset,
            radius * 2.4,
            [color.withOpacity(0.14), color.withOpacity(0.0)],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );

      // Core blurred blob
      canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            offset,
            radius,
            [
              color.withOpacity(0.60),
              color.withOpacity(0.28),
              color.withOpacity(0.0),
            ],
            [0.0, 0.55, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }
  }

  @override
  bool shouldRepaint(_RealBlobPainter old) =>
      old.stations != stations ||
          old.pollutant != pollutant ||
          old.camera   != camera;
}

// ─── Mock zone blob painter ──────────────────────────────────────────────────

class _MockBlobPainter extends CustomPainter {
  final List<AqiZone> zones;
  final MapCamera     camera;

  const _MockBlobPainter({required this.zones, required this.camera});

  @override
  void paint(Canvas canvas, Size size) {
    for (final z in zones) {
      final pt     = camera.latLngToScreenPoint(z.center);
      final offset = Offset(pt.x.toDouble(), pt.y.toDouble());
      final color  = z.color;
      const radius = 50.0;

      canvas.drawCircle(
        offset,
        radius * 2.2,
        Paint()
          ..shader = ui.Gradient.radial(
            offset,
            radius * 2.2,
            [color.withOpacity(0.12), color.withOpacity(0.0)],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );

      canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            offset,
            radius,
            [
              color.withOpacity(0.52),
              color.withOpacity(0.22),
              color.withOpacity(0.0),
            ],
            [0.0, 0.6, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_MockBlobPainter old) =>
      old.zones != zones || old.camera != camera;
}

// ─── AQI chip marker ─────────────────────────────────────────────────────────

class _AqiChip extends StatelessWidget {
  final double value;
  final String pollutant;
  final Color  color;
  final String label;

  const _AqiChip({
    required this.value,
    required this.pollutant,
    required this.color,
    required this.label,
  });

  bool get _darkText => color.computeLuminance() > 0.35;

  @override
  Widget build(BuildContext context) {
    final textColor    = _darkText ? const Color(0xFF1A1A2E) : Colors.white;
    final displayValue = value < 10
        ? value.toStringAsFixed(1)
        : value.toInt().toString();

    return Container(
      decoration: BoxDecoration(
        color:         color.withOpacity(0.90),
        borderRadius:  BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color:        color.withOpacity(0.40),
            blurRadius:   8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color:      Colors.black.withOpacity(0.20),
            blurRadius: 4,
            offset:     const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.30),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayValue,
            style: TextStyle(
              color:         textColor,
              fontSize:      13,
              fontWeight:    FontWeight.w800,
              height:        1.1,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color:         textColor.withOpacity(0.82),
              fontSize:      7,
              fontWeight:    FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}