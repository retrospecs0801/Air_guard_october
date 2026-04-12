// lib/map/services/aqi_map_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/map_data.dart';

class AqiMapService {
  static const _token     = '51bb235709d3bf96fe7f048bd31fec5a2e1fb33d';
  static const _cacheKey  = 'lucknow_aqi_v2';
  static const _cacheTime = 'lucknow_aqi_v2_ts';
  static const _ttlMs     = 30 * 60 * 1000; // 30 min

  // Urban Lucknow bounding box
  static const _latMin = 26.75, _latMax = 26.96;
  static const _lngMin = 80.88, _lngMax = 81.02;

  /// Returns live stations or falls back to hardcoded data.
  static Future<List<AqiStationPoint>> fetchStations() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = fromCache(prefs);
    if (cached != null) return cached;
    return _fetchAndCache(prefs);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTime);
  }

  static List<AqiStationPoint>? fromCache(SharedPreferences prefs) {
    final ts  = prefs.getInt(_cacheTime) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - ts > _ttlMs) return null;
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => AqiStationPoint.fromCacheJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<AqiStationPoint>> _fetchAndCache(
      SharedPreferences prefs) async {
    try {
      // Step 1: search
      final searchRes = await http
          .get(Uri.parse(
          'https://api.waqi.info/search/?keyword=lucknow&token=$_token'))
          .timeout(const Duration(seconds: 10));

      if (searchRes.statusCode != 200) return MockMapData.fallbackStations;
      final sj = jsonDecode(searchRes.body) as Map<String, dynamic>;
      if (sj['status'] != 'ok') return MockMapData.fallbackStations;

      // Step 2: filter to bbox + skip offline stations
      final uids = <int>[];
      for (final s in sj['data'] as List) {
        final geo = s['station']?['geo'] as List?;
        if (geo == null || geo.length < 2) continue;
        final lat = (geo[0] as num).toDouble();
        final lng = (geo[1] as num).toDouble();
        if (lat < _latMin || lat > _latMax) continue;
        if (lng < _lngMin || lng > _lngMax) continue;
        final aqiRaw = s['aqi'];
        if (aqiRaw == null || aqiRaw == '-' || aqiRaw == '') continue;
        final uid = s['uid'];
        if (uid != null) uids.add(uid as int);
      }

      if (uids.isEmpty) return MockMapData.fallbackStations;

      // Step 3: fetch each feed
      final responses = await Future.wait(
        uids.take(10).map((uid) => http
            .get(Uri.parse(
            'https://api.waqi.info/feed/@$uid/?token=$_token'))
            .timeout(const Duration(seconds: 8))),
        eagerError: false,
      );

      final results = <AqiStationPoint>[];
      for (final res in responses) {
        try {
          if (res.statusCode != 200) continue;
          final j    = jsonDecode(res.body) as Map<String, dynamic>;
          if (j['status'] != 'ok') continue;
          final data = j['data'] as Map<String, dynamic>;
          final iaqi = data['iaqi'] as Map<String, dynamic>? ?? {};

          final aqiRaw = data['aqi'];
          if (aqiRaw == null || aqiRaw == '-') continue;
          final aqi = (aqiRaw as num).toDouble();

          final geo = data['city']?['geo'] as List?;
          if (geo == null || geo.length < 2) continue;
          final lat = (geo[0] as num).toDouble();
          final lng = (geo[1] as num).toDouble();
          if (lat < _latMin || lat > _latMax) continue;
          if (lng < _lngMin || lng > _lngMax) continue;

          // Use real values when available; derive estimates otherwise.
          // PM2.5 ≈ 60% of AQI, NO2 ≈ 30%, PM10 ≈ 80% are conservative
          // Lucknow-specific estimates based on CPCB seasonal averages.
          final pm25raw = iaqi['pm25']?['v'];
          final no2raw  = iaqi['no2']?['v'];
          final pm10raw = iaqi['pm10']?['v'];

          results.add(AqiStationPoint(
            position:    LatLng(lat, lng),
            stationName: data['city']?['name'] ?? 'Unknown',
            aqi:         aqi,
            pm25: pm25raw != null ? (pm25raw as num).toDouble() : aqi * 0.60,
            no2:  no2raw  != null ? (no2raw  as num).toDouble() : aqi * 0.30,
            pm10: pm10raw != null ? (pm10raw as num).toDouble() : aqi * 0.80,
          ));
        } catch (_) {
          continue;
        }
      }

      if (results.isEmpty) return MockMapData.fallbackStations;

      // Cache
      await prefs.setString(
          _cacheKey, jsonEncode(results.map((e) => e.toJson()).toList()));
      await prefs.setInt(
          _cacheTime, DateTime.now().millisecondsSinceEpoch);

      return results;
    } catch (_) {
      return MockMapData.fallbackStations;
    }
  }
}