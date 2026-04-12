// lib/data/aqi_station_data.dart
//
// Fallback hardcoded station data for Lucknow.
// Used when SharedPreferences cache is empty or unavailable.
// Coordinates sourced from known landmark positions.

class FallbackStation {
  final String name;
  final double lat;
  final double lng;
  final double aqi;
  final double pm25;

  const FallbackStation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.aqi,
    required this.pm25,
  });
}

class AqiStationData {
  static const List<FallbackStation> lucknowStations = [
    FallbackStation(
      name: 'Talkatora',
      lat: 26.8467,
      lng: 80.9462,
      aqi: 161,
      pm25: 161,
    ),
    FallbackStation(
      name: 'Gomti Nagar',
      lat: 26.8553,
      lng: 80.9962,
      aqi: 156,
      pm25: 156,
    ),
    FallbackStation(
      name: 'Central School',
      lat: 26.8786,
      lng: 80.9398,
      aqi: 154,
      pm25: 154,
    ),
    FallbackStation(
      name: 'Lalbagh',
      lat: 26.8441,
      lng: 80.9168,
      aqi: 153,
      pm25: 153,
    ),
    FallbackStation(
      name: 'Kukrail Picnic Spot',
      lat: 26.8816,
      lng: 81.0169,
      aqi: 151,
      pm25: 151,
    ),
    FallbackStation(
      name: 'BR Ambedkar University',
      lat: 26.7606,
      lng: 80.9162,
      aqi: 109,
      pm25: 109,
    ),
  ];
}