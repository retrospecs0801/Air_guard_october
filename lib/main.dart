// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/exposure_service.dart';
import 'services/pollution_service.dart';

import 'recovery/recovery_module.dart';
import 'analytics/analytics_module.dart';
import 'community/community_screen.dart';

import 'analytics/analytics_screen.dart';
import 'health_profile_screen.dart';
import 'map/map_screen.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  runApp(const ExposureApp());
}

class ExposureApp extends StatelessWidget {
  const ExposureApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exposure - Set Home & Auto Counter',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter', // Global default

        // This section defines the "defaults" for different types of text
        textTheme: const TextTheme(
          // For "Pollution Exposure" Header (22px, w800)
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800, // Will use your Bold ttf
            color: Color(0xFF111827),
          ),
          // For the Large Score (56px)
          displayLarge: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: Color(0xFF111827),
          ),
          // For Body labels (Today, Session, etc.)
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500, // Will use your Medium ttf
            color: Color(0xFF6B7280),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  Future<void> _setSafeZoneToCurrentLocation() async {
    setState(() => _status = 'Updating safe zone to current location...');
    try {
      // 1. Get the current precise position
      final pos = await _loc.getCurrentPosition();

      // 2. Save it as the primary home/safe coordinates
      await StorageService.saveHome(pos.latitude, pos.longitude);

      // 3. Update the Exposure Service so the timer stops/starts immediately
      await _exposure.setHome(pos.latitude, pos.longitude);

      setState(() {
        _homeLat = pos.latitude;
        _homeLng = pos.longitude;
        _status = 'Safe zone updated to current location!';
      });

      // 4. Show a SnackBar for better user feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.verified_user, color: Colors.white),
                SizedBox(width: 10),
                Text('Location marked as Safe Zone'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _status = 'Failed to set safe zone: $e');
    }
  }

  final LocationService _loc = LocationService();
  final ExposureService _exposure = ExposureService();
  final PollutionService _pollution = PollutionService();

  Position? _currentPosition;
  double? _homeLat;
  double? _homeLng;
  String _status = 'Idle';

  StreamSubscription<Position>? _posSub;
  StreamSubscription<ExposureData>? _exposureSub;

  // UI state for exposure
  bool _isInside = true;
  Duration _totalExposure = Duration.zero;
  Duration _currentSession = Duration.zero;

  // UI state for pollution
  double? _lastKnownAqi;
  double? _currentAqi;
  double _pollutionDose = 0.0;
  String _doseMessage = 'Low';
  String? _aqiLocationName;

  late AnimationController _pulseController;

  // Add FocusNode for keyboard detection
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadHomeAndStart();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _exposureSub?.cancel();
    _exposure.dispose();
    _pulseController.dispose();
    _focusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  Future<void> _loadHomeAndStart() async {
    final savedDose = await StorageService.loadDose();
    if (mounted) {
      setState(() {
        _pollutionDose = savedDose;
      });
    }

    final home = await StorageService.loadHome();
    if (home != null) {
      _homeLat = home['lat'];
      _homeLng = home['lng'];
    }

    final ok = await _loc.ensurePermission();
    if (!ok) {
      setState(() => _status = 'Location permission missing');
      return;
    }

    _posSub = _loc.positionStream(accuracy: LocationAccuracy.best, distanceFilter: 0)
        .listen((pos) async {
      setState(() {
        _currentPosition = pos;
        _status = 'Location updated';
      });

      if (_currentAqi == null && !_isInside) {
        final aqiResult = await _pollution.getAqiForLocation(pos.latitude, pos.longitude);
        if (!mounted) return;
        setState(() {
          _currentAqi = aqiResult.aqi;
          _lastKnownAqi = aqiResult.aqi;
          _aqiLocationName = aqiResult.locationName;
          _status = aqiResult.status;
        });
      }
    }, onError: (e) {
      setState(() => _status = 'Position stream error: $e');
    });

    await _exposure.startMonitoring();

    if (_homeLat != null && _homeLng != null) {
      await _exposure.setHome(_homeLat!, _homeLng!);
    }

    _exposureSub = _exposure.stream.listen((data) {
      if (!mounted) return;

      final dose = _pollution.calculateDose(data.totalExposureToday, _currentAqi ?? _lastKnownAqi);
      final doseInfo = _pollution.getDoseMessage(dose);

      StorageService.saveDose(dose);

      setState(() {
        _isInside = data.isInsideHome;
        _totalExposure = data.totalExposureToday;
        _currentSession = data.currentSessionDuration;
        _pollutionDose = dose;
        _doseMessage = doseInfo.message;

        if (data.status != _status && data.status.isNotEmpty) {
          _status = data.status;
        }

        if (_isInside) {
          _currentAqi = null;
        }
      });
    });
  }

  //  Handle keyboard input for testing
  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      double? newDose;

      if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) {

        newDose = 90.0;
        _manualAqiRefresh();
      } else if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) {
        newDose = 160.0;
      } else if (event.logicalKey == LogicalKeyboardKey.digit3 || event.logicalKey == LogicalKeyboardKey.numpad3) {
        newDose = 350.0;
      } else if (event.logicalKey == LogicalKeyboardKey.digit4 || event.logicalKey == LogicalKeyboardKey.numpad4) {
        newDose = 600.0;
      }
     else if (event.logicalKey == LogicalKeyboardKey.digit5 || event.logicalKey == LogicalKeyboardKey.numpad5) {
      newDose = 00;
    }

      if (newDose != null) {
        final doseInfo = _pollution.getDoseMessage(newDose);
        StorageService.saveDose(newDose);

        setState(() {
          _pollutionDose = newDose!;
          _doseMessage = doseInfo.message;
          _status = 'Testing mode: Dose set to ${newDose.toInt()}';
        });

        // --- NEW: Trigger the API fetch ---
        _manualAqiRefresh();
      }
    }
  }

  Future<void> _setHomeToCurrentLocation() async {
    setState(() => _status = 'Requesting current location...');
    try {
      final pos = await _loc.getCurrentPosition();
      await StorageService.saveHome(pos.latitude, pos.longitude);
      setState(() {
        _homeLat = pos.latitude;
        _homeLng = pos.longitude;
      });

      await _exposure.setHome(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() => _status = 'Failed to set home: $e');
    }
  }

  Future<void> _clearHome() async {
    await StorageService.clearHome();
    await _exposure.clearHome();
    await StorageService.saveDose(0.0);

    setState(() {
      _homeLat = null;
      _homeLng = null;
      _status = 'Home cleared';
      _totalExposure = Duration.zero;
      _currentSession = Duration.zero;
      _pollutionDose = 0.0;
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    } else {
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
  }

  String _homeText() {
    if (_homeLat == null || _homeLng == null) return 'Not Set';
    return '${_homeLat!.toStringAsFixed(4)}, ${_homeLng!.toStringAsFixed(4)}';
  }

  String _currentLocationText() {
    if (_currentPosition == null) return 'Waiting for location...';
    return '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}';
  }

  String _distanceToHomeText() {
    if (_isInside) {
      return 'At Home';
    }

    if (_homeLat == null || _homeLng == null || _currentPosition == null) {
      return '-- m';
    }

    final distance = _loc.distanceBetween(
      _homeLat!,
      _homeLng!,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    if (distance > 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }

    return '${distance.toStringAsFixed(0)} m';
  }

  Map<String, dynamic> _getTheme() {
    switch (_doseMessage) {
      case 'Low':
        return {
          'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
          'iconColor': const Color(0xFF10b981),
          'icon': Icons.check_circle_rounded,
        };
      case 'Moderate':
        return {
          'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)],
          'iconColor': const Color(0xFFf59e0b),
          'icon': Icons.warning_rounded,
        };
      case 'High':
        return {
          'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)],
          'iconColor': const Color(0xFFef4444),
          'icon': Icons.error_rounded,
        };
      case 'Critical':
        return {
          'gradient': [const Color(0xFFeb3349), const Color(0xFFf45c43)],
          'iconColor': const Color(0xFFdc2626),
          'icon': Icons.dangerous_rounded,
        };
      default:
        return {
          'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
          'iconColor': const Color(0xFF10b981),
          'icon': Icons.check_circle_rounded,
        };
    }
  }
// Replace your existing build() method with this one.
// Only the build method changes — all your state, initState,
// and other methods remain exactly as they are.

  @override
  Widget build(BuildContext context) {
    Color exposureColor;
    Color cardBgColor;

    // Setting the primary color and a very soft pastel background for the main card
    if (_pollutionDose <= 100) {
      exposureColor = const Color(0xFF22C55E); // Green
      cardBgColor = const Color(0xFFF0FDF4);   // Soft Pastel Green
    } else if (_pollutionDose <= 200) {
      exposureColor = const Color(0xFFF59E0B); // Amber
      cardBgColor = const Color(0xFFFFFBEB);   // Soft Pastel Amber
    } else {
      exposureColor = const Color(0xFFEF4444); // Red
      cardBgColor = const Color(0xFFFEF2F2);   // Soft Pastel Red
    }

    return DefaultTabController(
      length: 3,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyPress,
        child: Scaffold(
          // A cooler, premium off-white background
          backgroundColor: const Color(0xFFF4F6F8),
          body: SafeArea(
            child: Column(
              children: [

                /// TAB BAR
                TabBar(
                  labelColor: const Color(0xFF111827),
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: const Color(0xFF1E293B), // Premium Deep Navy
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  tabs: const [
                    Tab(icon: PhosphorIcon(PhosphorIconsBold.house), text: "Home"),
                    Tab(icon: PhosphorIcon(PhosphorIconsBold.chartBar), text: "Predict"),
                    Tab(icon: PhosphorIcon(PhosphorIconsBold.mapPin), text: "Map"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: [

                      /// HOME TAB
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: Column(
                            children: [

                              /// HEADER
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HealthProfileScreen(),
                                        ),
                                      );
                                    },
                                    icon: const PhosphorIcon(
                                      PhosphorIconsBold.userCircle,
                                      size: 28,
                                      color: Color(0xFF111827),
                                    ),
                                  ),

                                  const Expanded(
                                    child: Center(
                                      child: Text(
                                        "Pollution Exposure",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 48), // Balances the Row
                                ],
                              ),

                              const SizedBox(height: 24),

                              /// MAIN EXPOSURE CARD (Dynamic Background)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: exposureColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [

                                    /// GOOGLE FIT STYLE CIRCULAR GAUGE
                                    SizedBox(
                                      height: 240,
                                      width: 240,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CircularProgressIndicator(
                                            value: (_pollutionDose / 500).clamp(0.0, 1.0),
                                            strokeWidth: 14,
                                            color: exposureColor,
                                            backgroundColor: exposureColor.withOpacity(0.15),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Exposure Score",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _pollutionDose.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 56,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -1.0,
                                                  height: 1.1,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: exposureColor.withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      )
                                                    ]
                                                ),
                                                child: Text(
                                                  _doseMessage.toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 12,
                                                    color: exposureColor,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    /// STRUCTURED STATS ROW
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _statTile(PhosphorIconsBold.timer, "Today", _formatDuration(_totalExposure)),
                                            VerticalDivider(color: Colors.grey.shade200, thickness: 1),
                                            _statTile(PhosphorIconsBold.personSimpleWalk, "Session", _formatDuration(_currentSession)),
                                            VerticalDivider(color: Colors.grey.shade200, thickness: 1),
                                            _statTile(PhosphorIconsBold.house, "Home", _distanceToHomeText()),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    /// AQI CARD
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(PhosphorIconsBold.mapPin, color: Colors.grey.shade700),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "AQI from: ${_aqiLocationName ?? "..."}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                Text(
                                                  "${_lastKnownAqi?.round() ?? "--"} AQI",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF111827),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              /// REAL-TIME STATUS CARD (New Addition)
                              _buildRealTimeStatusCard(),

                              const SizedBox(height: 24),

                              /// SET HOME CARD
                              _actionCard(
                                title: "Home Location",
                                icon: PhosphorIconsBold.house,
                                buttonText: "Set Home Here",
                                onPressed: _setHomeToCurrentLocation,
                              ),

                              if (_homeLat != null && _homeLng != null) ...[
                                const SizedBox(height: 12),
                                _secondaryButton("Clear Home", _clearHome),
                              ],

                              const SizedBox(height: 16),

                              /// SAFE ZONE BUTTON (Clean Outline)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _setSafeZoneToCurrentLocation,
                                  icon: const PhosphorIcon(PhosphorIconsBold.shieldCheck, size: 20),
                                  label: const Text(
                                    "Set Current Place as Safe Zone",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    foregroundColor: const Color(0xFF111827),
                                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              /// RECOVERY CARD
                              _actionCard(
                                title: "Recovery Plan",
                                icon: PhosphorIconsBold.arrowClockwise,
                                buttonText: "Generate Recovery",
                                color: const Color(0xFF4B5563), // Slate Grey
                                onPressed: () {
                                  RecoveryModule.launch(
                                    context,
                                    pollutionDose: _pollutionDose.toInt(),
                                    doseMessage: _doseMessage,
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              /// COMMUNITY CARD
                              _actionCard(
                                title: "Community Forum",
                                icon: PhosphorIconsBold.users,
                                buttonText: "Join Community",
                                color: const Color(0xFF0F766E), // Deep Medical Teal
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CommunityScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),

                      /// PREDICT TAB
                      Container(color: Colors.white, child: const AnalyticsScreen()),

                      /// MAP TAB
                      Container(color: Colors.white, child: const MapScreen()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REFINED HELPER WIDGETS ---

  Widget _statTile(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(icon, size: 22, color: const Color(0xFF6B7280)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildRealTimeStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              const PhosphorIcon(PhosphorIconsBold.broadcast, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 10),
              const Text(
                "Real-time monitoring active",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              // A small "Live" indicator dot
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E), // Green
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),

          /// STATUS MESSAGES
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PhosphorIcon(PhosphorIconsBold.info, color: Color(0xFF9CA3AF), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Using the existing _distanceToHomeText() logic
                    Text(
                      "Distance to Home: ${_distanceToHomeText()}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Placeholder for the missing sensor distance logic
                    const Text(
                      "AQI sensor distance: -- m away",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _actionCard({
    required String title,
    required IconData icon,
    required String buttonText,
    required VoidCallback onPressed,
    // Default changed to a premium Deep Navy instead of bright blue
    Color color = const Color(0xFF1E293B),
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // Sharper, cleaner corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PhosphorIcon(icon, size: 20, color: const Color(0xFF111827)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Structured button
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: const Color(0xFFEF4444), // Red for clear/delete actions
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _manualAqiRefresh() async {
    try {
      // 1. Get current position
      final pos = await _loc.getCurrentPosition();

      // 2. Fetch AQI from your existing service
      final aqiResult = await _pollution.getAqiForLocation(pos.latitude, pos.longitude);

      if (!mounted) return;

      // 3. Update the state variables used by the AQI Card
      setState(() {
        _currentPosition = pos;
        _lastKnownAqi = aqiResult.aqi;
        _aqiLocationName = aqiResult.locationName;
        _status = 'Manual Refresh: ${aqiResult.status}';
      });
    } catch (e) {
      setState(() => _status = 'Manual refresh failed: $e');
    }
  }
}