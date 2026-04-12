// lib/map/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models/map_data.dart';
import 'services/aqi_map_service.dart';
import 'widgets/aqi_heat_layer.dart';
import 'widgets/route_layer.dart';
import 'widgets/route_info_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();

  // ── State ────────────────────────────────────────────────
  bool _routesVisible = false;
  bool _demoMode      = false;
  String _selectedPollutant = 'aqi';
  List<AqiStationPoint> _stations = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stations = await AqiMapService.fetchStations();
    if (mounted) setState(() => _stations = stations);
  }

  void _showRoutes() {
    setState(() {
      _routesVisible = true;
      _demoMode      = true; // demo mode makes eco route contrast visible
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.move(const LatLng(26.8620, 80.9680), 12.8);
    });
  }

  void _resetRoutes() {
    setState(() {
      _routesVisible = false;
      _demoMode      = false;
    });
    _mapController.move(MockMapData.mapCenter, 13.2);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          flex: 62,
          child: Stack(
            children: [
              // ── Base map ─────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: MockMapData.mapCenter,
                  initialZoom:   13.2,
                  minZoom:       11,
                  maxZoom:       17,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.pollution_tracker',
                    maxZoom: 17,
                  ),

                  // Heat circles — demo mode uses mock zones, else real stations
                  if (_demoMode)
                    const AqiHeatLayer(mockZones: MockMapData.aqiZones)
                  else
                    AqiHeatLayer(
                      stations:          _stations.isNotEmpty
                          ? _stations
                          : MockMapData.fallbackStations,
                      selectedPollutant: _selectedPollutant,
                    ),

                  // Routes
                  if (_routesVisible) ...[
                    const DefaultRouteLayer(),
                    const EcoRouteLayer(),
                  ],

                  // Pins always visible
                  const RouteMarkersLayer(),
                ],
              ),

              // ── Top bar ──────────────────────────────────
              Positioned(
                top: 12, left: 12, right: 12,
                child: _TopBar(
                  demoMode:  _demoMode,
                  onDemo:    () => setState(() => _demoMode = !_demoMode),
                  onZoomIn:  () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1),
                  onZoomOut: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1),
                ),
              ),

              // ── Pollutant chip row (real data only, no demo) ──
              if (!_demoMode)
                Positioned(
                  bottom: 12, left: 16, right: 16,
                  child: _PollutantChipRow(
                    selected: _selectedPollutant,
                    onSelect: (key) =>
                        setState(() => _selectedPollutant = key),
                  ),
                ),

              // ── Route legend ─────────────────────────────
              if (_routesVisible)
                Positioned(
                  top: 76, left: 12,
                  child: _RouteLegend(),
                ),
            ],
          ),
        ),

        // ── Bottom card ───────────────────────────────────
        RouteInfoCard(
          routesVisible: _routesVisible,
          onCompare:     _showRoutes,
          onReset:       _resetRoutes,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool demoMode;
  final VoidCallback onDemo;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _TopBar({
    required this.demoMode,
    required this.onDemo,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:     const EdgeInsets.all(7),
            decoration:  BoxDecoration(
              color:        const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.air_rounded,
                color: Color(0xFF0F766E), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AQI Heat Map — Lucknow',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                Text(
                  'Live pollution zones · Tap Compare Routes',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Demo mode toggle
              GestureDetector(
                onTap: onDemo,
                child: Container(
                  width:  30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: demoMode
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: demoMode
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Icon(Icons.science_outlined,
                      size:  15,
                      color: demoMode
                          ? Colors.white
                          : Colors.grey.shade600),
                ),
              ),
              _ZoomBtn(icon: Icons.add, onTap: onZoomIn),
              const SizedBox(width: 4),
              _ZoomBtn(icon: Icons.remove, onTap: onZoomOut),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  30,
        height: 30,
        decoration: BoxDecoration(
          color:        const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 15, color: Colors.grey.shade600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Pollutant chip row
// ─────────────────────────────────────────────────────────
class _PollutantChipRow extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const _PollutantChipRow({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: kPollutants.map((p) {
            final active = selected == p.key;
            return GestureDetector(
              onTap: () => onSelect(p.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF1E293B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: active
                        ? Colors.white
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Route legend
// ─────────────────────────────────────────────────────────
class _RouteLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendRow(const Color(0xFFEF4444), 'Default Route', '18 min'),
          const SizedBox(height: 6),
          _legendRow(const Color(0xFF0F766E), 'Eco Route', '23 min'),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, String time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 3,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827))),
        const SizedBox(width: 6),
        Text(time,
            style: TextStyle(
                fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }
}