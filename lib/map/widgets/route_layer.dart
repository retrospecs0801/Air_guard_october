// lib/map/widgets/route_layer.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/map_data.dart';

class DefaultRouteLayer extends StatelessWidget {
  const DefaultRouteLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points:           MockMapData.defaultRoute.points,
          color:            MockMapData.defaultRoute.color,
          strokeWidth:      4.5,
          borderColor:      const Color(0xFF991B1B).withOpacity(0.35),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}

class EcoRouteLayer extends StatelessWidget {
  const EcoRouteLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points:           MockMapData.ecoRoute.points,
          color:            MockMapData.ecoRoute.color,
          strokeWidth:      4.5,
          borderColor:      const Color(0xFF134E4A).withOpacity(0.35),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}

class RouteMarkersLayer extends StatelessWidget {
  const RouteMarkersLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point:  MockMapData.origin,
          width:  36,
          height: 36,
          child:  _PinMarker(label: 'A', color: const Color(0xFF1E293B)),
        ),
        Marker(
          point:  MockMapData.destination,
          width:  36,
          height: 36,
          child:  _PinMarker(label: 'B', color: const Color(0xFF0F766E)),
        ),
      ],
    );
  }
}

class _PinMarker extends StatelessWidget {
  final String label;
  final Color  color;
  const _PinMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  36,
      height: 36,
      decoration: BoxDecoration(
        color:  color,
        shape:  BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color:      color.withOpacity(0.35),
            blurRadius: 8,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color:      Colors.white,
            fontWeight: FontWeight.w700,
            fontSize:   14,
          ),
        ),
      ),
    );
  }
}