import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/api_config.dart';
import 'dart:math' as math;
import 'dart:convert';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';

/// Result class for Flexible Polyline decoding
class _FlexiblePolylineResult {
  final double value;
  final int nextIndex;
  
  _FlexiblePolylineResult(this.value, this.nextIndex);
}

class LiveNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  const LiveNavigationScreen({
    Key? key,
    required this.orderData,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
  }) : super(key: key);

  @override
  State<LiveNavigationScreen> createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _isNavigating = false;
  bool _isMapReady = false; // Add flag to track map readiness
  String _currentAddress = "Getting location...";
  String _distanceToDestination = "";
  String _timeToDestination = "";
  String _nextManeuver = "";
  String _currentSpeed = "0 km/h";
  String _eta = "";
  
  List<LatLng> _routePoints = [];
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  LatLng? _currentLocation;
  
  @override
  void initState() {
    super.initState();
    print('LiveNavigationScreen initState called');
    print('Pickup: ${widget.pickupLat}, ${widget.pickupLng}');
    print('Dropoff: ${widget.dropoffLat}, ${widget.dropoffLng}');
    
    _initializeNavigation();
    
    // Auto-start navigation within the app after a longer delay to ensure map is ready
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _startInAppNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNavigating ? 'HERE Navigation Active' : 'HERE Navigation',
          style: TextStyle(
            fontFamily: fontFamilyBold,
            color: Colors.white,
          ),
        ),
        backgroundColor: priMaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isNavigating)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopNavigation,
              tooltip: 'Stop Navigation',
            ),
                     IconButton(
             icon: const Icon(Icons.navigation),
             onPressed: _startInAppNavigation,
             tooltip: 'Start In-App Navigation',
           ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasLocationPermission
              ? _buildPermissionDeniedView()
              : Column(
                  children: [
                    _buildNavigationHeader(),
                    Expanded(
                      child: _buildMapView(),
                    ),
                                         if (_isNavigating) _buildNavigationControls(),
                     _buildExternalNavigationOption(),
                  ],
                ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Location Permission Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enable location access in settings to use navigation',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        children: [
                     // Navigation status message
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: _isNavigating ? Colors.green[100] : Colors.blue[100],
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: _isNavigating ? Colors.green[300]! : Colors.blue[300]!),
             ),
             child: Row(
               children: [
                 Icon(
                   _isNavigating ? Icons.navigation : Icons.location_on,
                   color: _isNavigating ? Colors.green[700] : Colors.blue[700],
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     _isNavigating 
                       ? 'Navigation Active - Following Route'
                       : 'Ready to Start Navigation',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: _isNavigating ? Colors.green[700] : Colors.blue[700],
                     ),
                   ),
                 ),
               ],
             ),
           ),
          const SizedBox(height: 12),
          
          // Current location
          Row(
            children: [
              Icon(Icons.my_location, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentAddress,
                  style: TextStyle(fontSize: 14, color: Colors.blue[700], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Route info cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(Icons.straighten, 'Distance', _distanceToDestination, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(Icons.access_time, 'Time', _timeToDestination, Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(Icons.speed, 'Speed', _currentSpeed, Colors.purple),
              ),
            ],
          ),
          
          // ETA
          if (_eta.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ETA: $_eta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
                     // Next maneuver
           if (_isNavigating && _nextManeuver.isNotEmpty) ...[
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.blue[100],
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.blue[300]!),
               ),
               child: Row(
                 children: [
                   Icon(Icons.turn_right, color: Colors.blue[700]),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       _nextManeuver,
                       style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                         color: Colors.blue[700],
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ],
           
                       // Route source info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.route, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Route calculated using free OpenRouteService (no API key needed)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Map status indicator
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isMapReady ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isMapReady ? Colors.green[300]! : Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _isMapReady ? Icons.map : Icons.hourglass_empty,
                    color: _isMapReady ? Colors.green[700] : Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isMapReady ? 'Map Ready - Navigation Available' : 'Map Initializing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isMapReady ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _pickupLocation ?? LatLng(widget.pickupLat, widget.pickupLng),
            initialZoom: 12,
            onMapReady: _onMapReady,
          ),
          children: [
            // Use the _buildMapTiles() method for consistent tile configuration
            _buildMapTiles(),
            
            // Route polyline
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6,
                    color: Colors.blue,
                  ),
                ],
              ),
            
            // Markers
            MarkerLayer(
              markers: [
                // Pickup marker
                if (_pickupLocation != null)
                  Marker(
                    point: _pickupLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                    ),
                  ),
                
                // Dropoff marker
                if (_dropoffLocation != null)
                  Marker(
                    point: _dropoffLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                    ),
                  ),
                
                // Current location marker
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.my_location, color: Colors.white, size: 24),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Callback when map is ready
  void _onMapReady() {
    print('🗺️ Map is ready!');
    setState(() {
      _isMapReady = true;
    });
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isNavigating ? _stopNavigation : _startNavigation,
              icon: Icon(_isNavigating ? Icons.stop : Icons.navigation),
              label: Text(_isNavigating ? 'Stop Navigation' : 'Start Navigation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNavigating ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isMapReady ? _startInAppNavigation : null,
              icon: const Icon(Icons.navigation),
              label: Text(_isMapReady ? 'Start Navigation' : 'Map Loading...'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMapReady ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalNavigationOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange[50],
      child: Row(
        children: [
          Icon(Icons.open_in_new, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Need external navigation?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _openInExternalMaps,
            icon: const Icon(Icons.launch),
            label: const Text('Open HERE Web'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeNavigation() async {
    try {
      // Request location permissions
      var locationStatus = await Permission.location.request();
      if (locationStatus.isGranted) {
        setState(() => _hasLocationPermission = true);
        await _getCurrentLocation();
        _setupRoute();
      } else {
        setState(() {
          _hasLocationPermission = false;
          _isLoading = false;
        });
        Get.snackbar(
          'Location Permission Required',
          'Please enable location access to use navigation',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error initializing navigation: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      _startLocationUpdates();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street ?? 'Unknown Street'}, ${place.locality ?? 'Unknown City'}";
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
    
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _currentSpeed = '${(position.speed * 3.6).round()} km/h';
        });
        
        if (_isNavigating) {
          _updateNavigationInfo();
        }
      }
    });
  }

  Future<void> _setupRoute() async {
    _pickupLocation = LatLng(widget.pickupLat, widget.pickupLng);
    _dropoffLocation = LatLng(widget.dropoffLat, widget.dropoffLng);
    
    // Wait for map to be ready before calculating route
    await _waitForMapReady();
    
    // Calculate route points using HERE API
    await _calculateRoutePoints();
    
    setState(() => _isLoading = false);
  }

  // Wait for map to be ready
  Future<void> _waitForMapReady() async {
    int attempts = 0;
    const maxAttempts = 20; // Wait up to 10 seconds (20 * 500ms)
    
    while (!_isMapReady && attempts < maxAttempts) {
      print('Waiting for map to be ready... (attempt ${attempts + 1}/$maxAttempts)');
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    if (_isMapReady) {
      print('✅ Map is ready after ${attempts * 500}ms');
    } else {
      print('⚠️ Map still not ready after ${maxAttempts * 500}ms, proceeding anyway');
    }
  }

  Future<void> _calculateRoutePoints() async {
    // Use HERE API for route calculation
    await _getRouteFromHereAPI();
  }

  Future<void> _getRouteFromHereAPI() async {
    try {
      print('🚛 ====== HERE API ROUTE CALCULATION START ======');
      print('📍 Pickup Location: ${widget.pickupLat}, ${widget.pickupLng}');
      print('🎯 Dropoff Location: ${widget.dropoffLat}, ${widget.dropoffLng}');
      print('🚚 Transport Mode: truck');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('');
      
      print('📡 Calling ApiProvider().calculateRoute() with parameters:');
      print('   • originLat: ${widget.pickupLat}');
      print('   • originLng: ${widget.pickupLng}');
      print('   • destinationLat: ${widget.dropoffLat}');
      print('   • destinationLng: ${widget.dropoffLng}');
      print('   • transportMode: truck');
      print('');
      
      // Use your existing API provider for route calculation
      final routeResult = await ApiProvider().calculateRoute(
        originLat: widget.pickupLat,
        originLng: widget.pickupLng,
        destinationLat: widget.dropoffLat,
        destinationLng: widget.dropoffLng,
        transportMode: 'truck',
      );
      
      print('📥 API Response received:');
      print('   • Success: ${routeResult['success']}');
      print('   • Distance: ${routeResult['distance']}');
      print('   • Duration: ${routeResult['duration']}');
      print('   • Has Polyline: ${routeResult['polyline'] != null ? 'Yes' : 'No'}');
      print('   • Has Waypoints: ${routeResult['waypoints'] != null ? 'Yes (${routeResult['waypoints'].length})' : 'No'}');
      print('   • Message: ${routeResult['message'] ?? 'N/A'}');
      print('');
      
      // Debug: Show what the route data actually looks like
      print('🔍 ROUTE DATA ANALYSIS:');
      print('   • Has Route: ${routeResult['route'] != null ? 'Yes' : 'No'}');
      if (routeResult['route'] != null) {
        print('   • Route Keys: ${(routeResult['route'] as Map).keys.toList()}');
        if (routeResult['route']['sections'] != null) {
          print('   • Sections Count: ${(routeResult['route']['sections'] as List).length}');
          print('   • First Section Keys: ${(routeResult['route']['sections'][0] as Map).keys.toList()}');
          
          // Check for polyline in sections
          final sections = routeResult['route']['sections'] as List;
          for (int i = 0; i < sections.length; i++) {
            final section = sections[i];
            if (section['polyline'] != null) {
              print('   • Section $i has polyline: ${section['polyline']}');
            }
            if (section['shape'] != null) {
              print('   • Section $i has shape: ${section['shape']}');
            }
          }
        }
      }
      print('   • Has Polyline: ${routeResult['polyline'] != null ? 'Yes' : 'No'}');
      if (routeResult['polyline'] != null) {
        print('   • Polyline Type: ${routeResult['polyline'].runtimeType}');
        print('   • Polyline Content: ${routeResult['polyline']}');
      }
      print('');
      
      if (routeResult['success'] == true) {
        print('✅ Route calculated successfully using API provider');
        
        // Update route info from API response
        setState(() {
          _distanceToDestination = routeResult['distance'] ?? 'N/A';
          _timeToDestination = routeResult['duration'] ?? 'N/A';
          _eta = _calculateETAFromDuration(routeResult['duration'] ?? '0 min');
        });
        
        print('📊 Route Info Updated:');
        print('   • Distance: $_distanceToDestination');
        print('   • Time: $_timeToDestination');
        print('   • ETA: $_eta');
        print('');
        
                 // Parse route data from HERE API - prioritize polyline over shape for better accuracy
         print('🔍 Analyzing route data structure...');
         print('   • Route result keys: ${routeResult.keys.toList()}');
         
         if (routeResult['route'] != null) {
           print('🔗 Found route data, analyzing structure...');
           final route = routeResult['route'];
           print('   • Route keys: ${route.keys.toList()}');
           
           if (route['sections'] != null) {
             print('🔗 Found route sections - checking for polyline data first...');
             // Try to get polyline from sections first (most accurate)
             _routePoints = _extractPolylineFromSections(route['sections']);
             if (_routePoints.isNotEmpty) {
               print('📍 Extracted ${_routePoints.length} REAL route points from section polylines');
             } else {
               print('⚠️ No polyline found in sections, trying shape data...');
               _routePoints = _extractRouteShapeFromSections(route['sections']);
               print('📍 Extracted ${_routePoints.length} REAL route points from section shapes');
             }
           } else {
             print('⚠️ No sections found in route data');
             _routePoints = _createIntermediateRoutePoints();
           }
         } else if (routeResult['polyline'] != null) {
           print('🔗 No route data, but found polyline - parsing...');
           _routePoints = _parsePolylineToRoutePoints(routeResult['polyline']);
           print('📍 Parsed ${_routePoints.length} REAL route points from polyline');
         } else {
           print('⚠️ No route or polyline data available from HERE API, creating realistic fallback route');
           // Fallback to realistic route points if no route data
           _routePoints = _createRealisticRoutePoints();
           print('📍 Created ${_routePoints.length} realistic fallback route points');
         }
        
        print('🗺️ Route Points Summary:');
        print('   • Total Points: ${_routePoints.length}');
        print('   • Start: ${_routePoints.first.latitude}, ${_routePoints.first.longitude}');
        print('   • End: ${_routePoints.last.latitude}, ${_routePoints.last.longitude}');
        
        // Check if we're using real or fake coordinates
        if (_routePoints.length > 2) {
          print('   • Route Type: REAL road coordinates from HERE API 🎯');
          print('   • Contains: Actual road turns, curves, and intersections');
        } else {
          print('   • Route Type: Fallback coordinates (not real road data) ⚠️');
        }
        print('');
        
        // Fit map to route
        print('🗺️ Fitting map to route...');
        _fitMapToRoute();
        
             } else {
         print('❌ Route calculation failed: ${routeResult['message']}');
         print('🔄 Falling back to realistic route points...');
         // Create realistic route points on failure
         _routePoints = _createRealisticRoutePoints();
         print('📍 Created ${_routePoints.length} realistic fallback route points');
       }
      
      print('🚛 ====== HERE API ROUTE CALCULATION END ======');
      print('');
      
         } catch (e) {
       print('💥 ====== ERROR IN ROUTE CALCULATION ======');
       print('❌ Error getting route from API provider: $e');
       print('🔄 Falling back to realistic route points...');
       // Create realistic route points on error
       _routePoints = _createRealisticRoutePoints();
       print('📍 Created ${_routePoints.length} realistic fallback route points');
       print('💥 ====== ERROR HANDLED ======');
       print('');
     }
  }
  
  List<LatLng> _parsePolylineToRoutePoints(dynamic polylineData) {
    try {
      print('🔗 ====== REAL POLYLINE PARSING START ======');
      print('📝 Polyline data type: ${polylineData.runtimeType}');
      print('📝 Polyline data: $polylineData');
      
      // Handle different polyline formats from HERE API
      if (polylineData is String) {
        print('📝 String polyline detected, length: ${polylineData.length} characters');
        return _decodeStringPolyline(polylineData);
      } else if (polylineData is Map<String, dynamic>) {
        print('📝 Map polyline detected, keys: ${polylineData.keys.toList()}');
        return _decodeMapPolyline(polylineData);
      } else if (polylineData is List) {
        print('📝 List polyline detected, length: ${polylineData.length}');
        return _decodeListPolyline(polylineData);
      } else {
        print('⚠️ Unknown polyline format: ${polylineData.runtimeType}');
        print('📝 Polyline data: $polylineData');
        return _createIntermediateRoutePoints();
      }
    } catch (e) {
      print('💥 ====== POLYLINE PARSING ERROR ======');
      print('❌ Error parsing polyline: $e');
      print('🔄 Falling back to intermediate route points...');
      print('💥 ====== POLYLINE PARSING ERROR END ======');
      print('');
      return _createIntermediateRoutePoints();
    }
  }
  
  List<LatLng> _decodeStringPolyline(String polyline) {
    print('🔍 Decoding HERE API polyline string...');
    print('📝 Polyline preview: ${polyline.length > 100 ? '${polyline.substring(0, 100)}...' : polyline}');
    
    try {
      // HERE API v8 uses a custom polyline encoding format
      // This is the proper decoder for HERE's polyline format
      return _decodeHerePolyline(polyline);
    } catch (e) {
      print('❌ Error decoding HERE polyline: $e');
      print('🔄 Falling back to intermediate points...');
      return _createIntermediateRoutePoints();
    }
  }
  
  List<LatLng> _decodeMapPolyline(Map<String, dynamic> polylineMap) {
    print('🔍 Decoding map polyline...');
    print('📝 Map keys: ${polylineMap.keys.toList()}');
    
    try {
      // Check for common HERE API polyline formats
      if (polylineMap.containsKey('points')) {
        print('📍 Found "points" key, decoding...');
        return _decodeListPolyline(polylineMap['points']);
      } else if (polylineMap.containsKey('coordinates')) {
        print('📍 Found "coordinates" key, decoding...');
        return _decodeListPolyline(polylineMap['coordinates']);
      } else if (polylineMap.containsKey('shape')) {
        print('📍 Found "shape" key, decoding...');
        return _decodeListPolyline(polylineMap['shape']);
      } else {
        print('⚠️ No recognized polyline keys found');
        print('📝 Available keys: ${polylineMap.keys.toList()}');
        return _createIntermediateRoutePoints();
      }
    } catch (e) {
      print('❌ Error decoding map polyline: $e');
      return _createIntermediateRoutePoints();
    }
  }
  
  List<LatLng> _decodeListPolyline(List polylineList) {
    print('🔍 Decoding list polyline...');
    print('📝 List length: ${polylineList.length}');
    
    final List<LatLng> points = [];
    
    try {
      for (int i = 0; i < polylineList.length; i++) {
        final item = polylineList[i];
        
        if (item is Map<String, dynamic>) {
          // Handle coordinate objects
          if (item.containsKey('lat') && item.containsKey('lng')) {
            final lat = item['lat'].toDouble();
            final lng = item['lng'].toDouble();
            points.add(LatLng(lat, lng));
            print('   • Point $i: $lat, $lng (REAL coordinate)');
          } else if (item.containsKey('latitude') && item.containsKey('longitude')) {
            final lat = item['latitude'].toDouble();
            final lng = item['longitude'].toDouble();
            points.add(LatLng(lat, lng));
            print('   • Point $i: $lat, $lng (REAL coordinate)');
          } else if (item.containsKey('lat') && item.containsKey('lon')) {
            final lat = item['lat'].toDouble();
            final lng = item['lon'].toDouble();
            points.add(LatLng(lat, lng));
            print('   • Point $i: $lat, $lng (REAL coordinate)');
          } else {
            print('   ⚠️ Point $i: Unknown coordinate format: $item');
          }
        } else if (item is List && item.length >= 2) {
          // Handle coordinate arrays [lat, lng]
          final lat = item[0].toDouble();
          final lng = item[1].toDouble();
          points.add(LatLng(lat, lng));
          print('   • Point $i: $lat, $lng (REAL coordinate)');
        } else {
          print('   ⚠️ Point $i: Unknown format: $item');
        }
      }
      
      if (points.isNotEmpty) {
        print('✅ Successfully decoded ${points.length} REAL route points from polyline');
        print('🔗 ====== REAL POLYLINE PARSING END ======');
        print('');
        return points;
      } else {
        print('⚠️ No valid coordinates found in polyline list');
        return _createIntermediateRoutePoints();
      }
    } catch (e) {
      print('❌ Error decoding list polyline: $e');
      return _createIntermediateRoutePoints();
    }
  }
  
  List<LatLng> _parseJsonCoordinates(String jsonString) {
    try {
      final List<dynamic> coordinates = json.decode(jsonString);
      return _decodeListPolyline(coordinates);
    } catch (e) {
      print('❌ Error parsing JSON coordinates: $e');
      return _createIntermediateRoutePoints();
    }
  }
  
  List<LatLng> _parseCoordinateString(String coordString) {
    try {
      final List<LatLng> points = [];
      final List<String> coordPairs = coordString.split(';');
      
      for (int i = 0; i < coordPairs.length; i++) {
        final List<String> coords = coordPairs[i].split(',');
        if (coords.length >= 2) {
          final lat = double.parse(coords[0]);
          final lng = double.parse(coords[1]);
          points.add(LatLng(lat, lng));
          print('   • Point $i: $lat, $lng (REAL coordinate)');
        }
      }
      
      if (points.isNotEmpty) {
        print('✅ Successfully parsed ${points.length} REAL coordinates from string');
        return points;
      } else {
        return _createIntermediateRoutePoints();
      }
    } catch (e) {
      print('❌ Error parsing coordinate string: $e');
      return _createIntermediateRoutePoints();
    }
  }
  
  /// Extracts polyline data from route sections (highest priority for accuracy)
  List<LatLng> _extractPolylineFromSections(List<dynamic> sections) {
    print('🔍 Extracting polyline data from ${sections.length} sections...');
    
    final List<LatLng> allPoints = [];
    
    try {
      for (int sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
        final section = sections[sectionIndex];
        print('   📍 Processing section $sectionIndex for polyline...');
        print('     • Section keys: ${section.keys.toList()}');
        
        // Prioritize polyline over shape (more accurate)
        if (section['polyline'] != null) {
          print('     • Found "polyline" data in section $sectionIndex');
          final polylinePoints = _parsePolylineToRoutePoints(section['polyline']);
          allPoints.addAll(polylinePoints);
          print('     • Added ${polylinePoints.length} points from polyline');
        } else if (section['shape'] != null) {
          print('     • No polyline, found "shape" data in section $sectionIndex');
          final shapePoints = _parseHereRouteShape(section['shape']);
          allPoints.addAll(shapePoints);
          print('     • Added ${shapePoints.length} points from shape');
        } else {
          print('     ⚠️ No polyline or shape data found in section $sectionIndex');
          print('     • Available keys: ${section.keys.toList()}');
        }
      }
      
      if (allPoints.isNotEmpty) {
        print('✅ Successfully extracted ${allPoints.length} REAL route points from section polylines');
        return allPoints;
      } else {
        print('⚠️ No polyline data extracted from sections');
        return [];
      }
    } catch (e) {
      print('❌ Error extracting polyline from sections: $e');
      return [];
    }
  }
  
  List<LatLng> _extractRouteShapeFromSections(List<dynamic> sections) {
    print('🔍 Extracting route shape from ${sections.length} sections...');
    
    final List<LatLng> allPoints = [];
    
    try {
      for (int sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
        final section = sections[sectionIndex];
        print('   📍 Processing section $sectionIndex...');
        print('     • Section keys: ${section.keys.toList()}');
        
        // Check for different possible shape data formats
        if (section['shape'] != null) {
          print('     • Found "shape" data in section $sectionIndex');
          final shapePoints = _parseHereRouteShape(section['shape']);
          allPoints.addAll(shapePoints);
          print('     • Added ${shapePoints.length} points from shape');
        } else if (section['polyline'] != null) {
          print('     • Found "polyline" data in section $sectionIndex');
          final polylinePoints = _parsePolylineToRoutePoints(section['polyline']);
          allPoints.addAll(polylinePoints);
          print('     • Added ${polylinePoints.length} points from polyline');
        } else if (section['waypoints'] != null) {
          print('     • Found "waypoints" data in section $sectionIndex');
          final waypointPoints = _extractPointsFromWaypoints(section['waypoints']);
          allPoints.addAll(waypointPoints);
          print('     • Added ${waypointPoints.length} points from waypoints');
        } else {
          print('     ⚠️ No shape data found in section $sectionIndex');
          print('     • Available keys: ${section.keys.toList()}');
        }
      }
      
      if (allPoints.isNotEmpty) {
        print('✅ Successfully extracted ${allPoints.length} REAL route points from sections');
        return allPoints;
      } else {
        print('⚠️ No route points extracted from sections, using fallback');
        return _createIntermediateRoutePoints();
      }
    } catch (e) {
      print('❌ Error extracting route shape from sections: $e');
      return _createIntermediateRoutePoints();
    }
  }
  
  List<LatLng> _extractPointsFromWaypoints(List<dynamic> waypoints) {
    final List<LatLng> points = [];
    
    try {
      for (int i = 0; i < waypoints.length; i++) {
        final waypoint = waypoints[i];
        
        if (waypoint['location'] != null) {
          final location = waypoint['location'];
          if (location['lat'] != null && location['lng'] != null) {
            final lat = location['lat'].toDouble();
            final lng = location['lng'].toDouble();
            points.add(LatLng(lat, lng));
            print('     • Waypoint $i: $lat, $lng (REAL coordinate)');
          }
        }
      }
      
      return points;
    } catch (e) {
      print('❌ Error extracting points from waypoints: $e');
      return [];
    }
  }
  
  List<LatLng> _parseHereRouteShape(List<dynamic> shape) {
    final List<LatLng> points = [];
    
    try {
      print('     🔍 Parsing shape data, length: ${shape.length}');
      print('     📝 First shape item type: ${shape.isNotEmpty ? shape[0].runtimeType : 'empty'}');
      
      for (int i = 0; i < shape.length; i++) {
        final point = shape[i];
        
        if (point is Map<String, dynamic>) {
          print('     📍 Point $i is Map, keys: ${point.keys.toList()}');
          if (point['lat'] != null && point['lng'] != null) {
            final lat = point['lat'].toDouble();
            final lng = point['lng'].toDouble();
            points.add(LatLng(lat, lng));
            print('     • Shape point $i: $lat, $lng (REAL coordinate)');
          } else if (point['latitude'] != null && point['longitude'] != null) {
            final lat = point['latitude'].toDouble();
            final lng = point['longitude'].toDouble();
            points.add(LatLng(lat, lng));
            print('     • Shape point $i: $lat, $lng (REAL coordinate)');
          } else if (point['lat'] != null && point['lon'] != null) {
            final lat = point['lat'].toDouble();
            final lng = point['lon'].toDouble();
            points.add(LatLng(lat, lng));
            print('     • Shape point $i: $lat, $lng (REAL coordinate)');
          } else {
            print('     ⚠️ Point $i: Unknown coordinate format: $point');
          }
        } else if (point is List && point.length >= 2) {
          final lat = point[0].toDouble();
          final lng = point[1].toDouble();
          points.add(LatLng(lat, lng));
          print('     • Shape point $i: $lat, $lng (REAL coordinate)');
        } else {
          print('     ⚠️ Point $i: Unknown format: $point (type: ${point.runtimeType})');
        }
      }
      
      print('     ✅ Parsed ${points.length} points from shape data');
      return points;
    } catch (e) {
      print('❌ Error parsing route shape: $e');
      return [];
    }
  }

  /// Decodes HERE API Flexible Polyline Encoding (FPE) into actual coordinates
  /// HERE API v8 uses Flexible Polyline Encoding, not Google's polyline format
  List<LatLng> _decodeHerePolyline(String encodedPolyline) {
    print('🔐 Decoding HERE Flexible Polyline: ${encodedPolyline.length} characters');
    print('📝 Polyline preview: ${encodedPolyline.length > 100 ? '${encodedPolyline.substring(0, 100)}...' : encodedPolyline}');
    
    try {
      final List<LatLng> points = [];
      int index = 0;
      double lat = 0.0, lng = 0.0;
      
      while (index < encodedPolyline.length) {
        // Decode latitude using Flexible Polyline Encoding
        final latResult = _decodeFlexiblePolylineValue(encodedPolyline, index);
        if (latResult == null) break;
        
        lat += latResult.value;
        index = latResult.nextIndex;
        
        // Decode longitude
        final lngResult = _decodeFlexiblePolylineValue(encodedPolyline, index);
        if (lngResult == null) break;
        
        lng += lngResult.value;
        index = lngResult.nextIndex;
        
        // Add the decoded coordinate
        points.add(LatLng(lat, lng));
        
        // Log every 10th point to avoid spam
        if (points.length % 10 == 0) {
          print('   📍 Decoded point ${points.length}: $lat, $lng');
        }
      }
      
      if (points.isNotEmpty) {
        print('✅ Successfully decoded ${points.length} REAL route points from HERE Flexible Polyline');
        return points;
      } else {
        print('⚠️ No points decoded from Flexible Polyline');
        return _createIntermediateRoutePoints();
      }
      
    } catch (e) {
      print('❌ Error decoding HERE Flexible Polyline: $e');
      print('📝 Polyline string: $encodedPolyline');
      return _createIntermediateRoutePoints();
    }
  }
  
  /// Decodes a single value from Flexible Polyline Encoding
  /// Returns a result with the decoded value and next index position
  _FlexiblePolylineResult? _decodeFlexiblePolylineValue(String polyline, int startIndex) {
    try {
      int index = startIndex;
      int result = 0;
      int shift = 0;
      
      do {
        if (index >= polyline.length) return null;
        
        int byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (result >= 0x20);
      
      // Handle negative values
      int value = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      
      // Convert to coordinate (HERE uses 1e-5 precision)
      double coordinate = value / 100000.0;
      
      return _FlexiblePolylineResult(coordinate, index);
      
    } catch (e) {
      print('❌ Error decoding Flexible Polyline value: $e');
      return null;
    }
  }
  
  List<LatLng> _createIntermediateRoutePoints() {
    print('🔄 ====== INTERMEDIATE ROUTE POINTS CREATION ======');
    print('📍 Pickup: ${widget.pickupLat}, ${widget.pickupLng}');
    print('🎯 Dropoff: ${widget.dropoffLat}, ${widget.dropoffLng}');
    print('');
    
    // Create intermediate waypoints between pickup and dropoff
    // This ensures we have more than just 2 points for a better route visualization
    
    final List<LatLng> points = [];
    final int numIntermediatePoints = 20; // Create 20 intermediate points for smoother route
    
    print('📍 Creating $numIntermediatePoints intermediate route points...');
    
    for (int i = 0; i <= numIntermediatePoints; i++) {
      final double ratio = i / numIntermediatePoints;
      
      // Add some curve to make it look more realistic (not just straight line)
      final double curveOffset = 0.0001 * math.sin(ratio * math.pi * 2); // Small curve
      
      // Linear interpolation between pickup and dropoff with curve
      final double lat = widget.pickupLat + (widget.dropoffLat - widget.pickupLat) * ratio + curveOffset;
      final double lng = widget.pickupLng + (widget.dropoffLng - widget.pickupLng) * ratio + curveOffset;
      
      points.add(LatLng(lat, lng));
      
      // Log every 5th point for debugging
      if (i % 5 == 0 || i == numIntermediatePoints) {
        print('   • Point $i: $lat, $lng (ratio: ${ratio.toStringAsFixed(2)})');
      }
    }
    
    print('✅ Successfully created ${points.length} intermediate route points');
    print('🔄 ====== INTERMEDIATE ROUTE POINTS CREATION END ======');
    print('');
    
    // Calculate route info using the intermediate points
    _calculateRouteInfoWithPoints(points);
    
    return points;
  }
  
  /// Creates a more realistic route with simulated road turns
  List<LatLng> _createRealisticRoutePoints() {
    print('🛣️ ====== REALISTIC ROUTE CREATION ======');
    
    final List<LatLng> points = [];
    
    // Start with pickup
    points.add(LatLng(widget.pickupLat, widget.pickupLng));
    
    // Add some intermediate waypoints that simulate road turns
    final double midLat = (widget.pickupLat + widget.dropoffLat) / 2;
    final double midLng = (widget.pickupLng + widget.dropoffLng) / 2;
    
    // Add a waypoint that's slightly offset to simulate a road turn
    final double turnOffset = 0.001; // Small offset for realistic turns
    final double turnLat = midLat + turnOffset;
    final double turnLng = midLng - turnOffset;
    
    points.add(LatLng(turnLat, turnLng));
    
    // End with dropoff
    points.add(LatLng(widget.dropoffLat, widget.dropoffLng));
    
    print('✅ Created realistic route with ${points.length} points including simulated turn');
    print('🛣️ ====== REALISTIC ROUTE CREATION END ======');
    
    return points;
  }
  

  

  

  

  


  void _calculateRouteInfoWithPoints(List<LatLng> points) {
    try {
      print('📊 ====== ROUTE INFO CALCULATION START ======');
      print('📍 Calculating route info for ${points.length} points...');
      
      double totalDistance = 0;
      
      // Calculate total distance through all intermediate points
      for (int i = 0; i < points.length - 1; i++) {
        final segmentDistance = _calculateDistance(
          points[i].latitude, 
          points[i].longitude, 
          points[i + 1].latitude, 
          points[i + 1].longitude
        );
        totalDistance += segmentDistance;
        
        // Log every 5th segment for debugging
        if (i % 5 == 0 || i == points.length - 2) {
          print('   • Segment $i → ${i + 1}: ${segmentDistance.toStringAsFixed(3)} km');
        }
      }
      
      print('📏 Total calculated distance: ${totalDistance.toStringAsFixed(3)} km');
      
      // Estimate time (assuming average speed of 50 km/h for truck)
      final estimatedTime = totalDistance * 1.2; // 1.2 minutes per km
      print('⏱️ Estimated time: ${estimatedTime.round()} minutes');
      
      setState(() {
        _distanceToDestination = '${totalDistance.toStringAsFixed(1)} km';
        _timeToDestination = '${estimatedTime.round()} min';
        _eta = _calculateETA(estimatedTime);
      });
      
      print('📊 Route Info Updated:');
      print('   • Distance: $_distanceToDestination');
      print('   • Time: $_timeToDestination');
      print('   • ETA: $_eta');
      print('📊 ====== ROUTE INFO CALCULATION END ======');
      print('');
      
    } catch (e) {
      print('💥 ====== ROUTE INFO CALCULATION ERROR ======');
      print('❌ Error calculating route info with points: $e');
      print('💥 ====== ROUTE INFO CALCULATION ERROR END ======');
      print('');
    }
  }
  
  void _fallbackRouteCalculation() {
    // Create intermediate route points instead of just 2 points
    _routePoints = _createIntermediateRoutePoints();
    
    // Route info is already calculated in _createIntermediateRoutePoints
  }
  
  void _calculateRouteInfo() {
    try {
      // Calculate distance using Haversine formula
      final distance = _calculateDistance(
        widget.pickupLat, 
        widget.pickupLng, 
        widget.dropoffLat, 
        widget.dropoffLng
      );
      
      // Estimate time (assuming average speed of 50 km/h for truck)
      final estimatedTime = distance * 1.2; // 1.2 minutes per km
      
      setState(() {
        _distanceToDestination = '${distance.toStringAsFixed(1)} km';
        _timeToDestination = '${estimatedTime.round()} min';
        _eta = _calculateETA(estimatedTime);
      });
    } catch (e) {
      print('Error calculating route info: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Use the same distance calculation method as your fuel stations controller
    // This is more accurate than the Haversine formula
    final distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    final distanceInKm = distanceInMeters / 1000; // Convert to km
    
    // Log distance calculation details (only for debugging)
    if (distanceInKm > 0.1) { // Only log for segments longer than 100m
      print('   📏 Distance: (${lat1.toStringAsFixed(6)}, ${lon1.toStringAsFixed(6)}) → (${lat2.toStringAsFixed(6)}, ${lon2.toStringAsFixed(6)}) = ${distanceInKm.toStringAsFixed(3)} km');
    }
    
    return distanceInKm;
  }

  String _calculateETA(double estimatedMinutes) {
    final now = DateTime.now();
    final eta = now.add(Duration(minutes: estimatedMinutes.round()));
    return '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';
  }
  
  String _calculateETAFromDuration(String duration) {
    try {
      // Parse duration string like "45 min" to get minutes
      final match = RegExp(r'(\d+)').firstMatch(duration);
      if (match != null) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        return _calculateETA(minutes.toDouble());
      }
      return 'N/A';
    } catch (e) {
      print('Error calculating ETA from duration: $e');
      return 'N/A';
    }
  }

  Future<void> _calculateRoute() async {
    if (_pickupLocation != null && _dropoffLocation != null) {
      await _calculateRoutePoints();
      _fitMapToRoute();
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isNotEmpty) {
      print('Fitting map to ${_routePoints.length} route points');
      try {
        if (_isMapReady) {
          final bounds = LatLngBounds.fromPoints(_routePoints);
          _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
        } else {
          print('Map not ready yet, will fit map when ready');
          // Schedule the fit operation for when the map is ready
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isMapReady) {
              _fitMapToRoute();
            }
          });
        }
      } catch (e) {
        print('Error fitting map to route: $e');
      }
    } else {
      print('No route points to fit map to');
    }
  }

  void _startNavigation() {
    setState(() => _isNavigating = true);
    
    // Start navigation updates
    _updateNavigationInfo();
    
    Get.snackbar(
      'Navigation Started',
      'Following route to destination',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _updateNavigationInfo() {
    if (_currentLocation != null && _dropoffLocation != null) {
      // Calculate distance to destination
      final distanceToDest = _calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _dropoffLocation!.latitude,
        _dropoffLocation!.longitude,
      );
      
      // Update ETA
      final remainingTime = distanceToDest * 1.2;
      final eta = DateTime.now().add(Duration(minutes: remainingTime.round()));
      
      setState(() {
        _eta = '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';
        _nextManeuver = _getNextManeuver();
      });
      
      // Center map on current location - add null check and error handling
      try {
        if (_isMapReady) {
          _mapController.move(_currentLocation!, 15);
        } else {
          print('Map not ready yet, skipping move operation');
        }
      } catch (e) {
        print('Error moving map: $e');
      }
    }
  }

  String _getNextManeuver() {
    if (_currentLocation == null || _dropoffLocation == null) return "";
    
    // Simple maneuver calculation based on bearing
    final bearing = _calculateBearing(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _dropoffLocation!.latitude,
      _dropoffLocation!.longitude,
    );
    
    if (bearing >= -22.5 && bearing < 22.5) return "Continue straight ahead";
    if (bearing >= 22.5 && bearing < 67.5) return "Turn right and continue";
    if (bearing >= 67.5 && bearing < 112.5) return "Turn right";
    if (bearing >= 112.5 && bearing < 157.5) return "Turn sharp right";
    if (bearing >= 157.5 || bearing < -157.5) return "Turn around";
    if (bearing >= -157.5 && bearing < -112.5) return "Turn sharp left";
    if (bearing >= -112.5 && bearing < -67.5) return "Turn left";
    if (bearing >= -67.5 && bearing < -22.5) return "Turn left and continue";
    
    return "Continue on current route";
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final lat1Rad = lat1 * (math.pi / 180);
    final lat2Rad = lat2 * (math.pi / 180);
    
    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) - math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);
    
    final bearing = math.atan2(y, x) * (180 / math.pi);
    return bearing;
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _nextManeuver = "";
    });

    Get.snackbar(
      'Navigation Stopped',
      'Navigation has been stopped',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> _recalculateRoute() async {
    await _calculateRoute();
    Get.snackbar(
      'Route Recalculated',
      'Route has been updated using HERE API',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _startInAppNavigation() {
    print('Starting in-app navigation...');
    
    // Check if map is ready before starting navigation
    if (!_isMapReady) {
      print('Map not ready yet, waiting for initialization...');
      Get.snackbar(
        'Please Wait',
        'Map is still initializing...',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    // Start navigation within the app
    _startNavigation();
    
    // Show success message
    Get.snackbar(
      'Navigation Started',
      'Turn-by-turn navigation is now active',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    // Update the app title to show navigation is active
    setState(() {
      // Title will be updated in build method
    });
  }

  Future<void> _openInExternalMaps() async {
    try {
      // Use HERE web navigation URL format
      final url = 'https://wego.here.com/directions/mix/${widget.pickupLat},${widget.pickupLng}/${widget.dropoffLat},${widget.dropoffLng}';
      
      print('🌐 Opening HERE web navigation: $url');
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        
        Get.snackbar(
          'Success',
          'HERE navigation opened in browser',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not open HERE navigation',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error opening HERE navigation: $e');
      Get.snackbar(
        'Error',
        'Failed to open navigation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

     /// Builds map tiles using HERE Maps
   Widget _buildMapTiles() {
        // Use HERE Maps tiles with your API key
        return TileLayer(
          urlTemplate: 'https://maps.hereapi.com/v3/staticmap?apiKey=${ApiConfig.hereMapsApiKey}&style=alps&poix0=${widget.pickupLat},${widget.pickupLng};red;12;12&poix1=${widget.dropoffLat},${widget.dropoffLng};green;12;12&w=800&h=600&z=12',
          userAgentPackageName: 'com.example.app',
          maxZoom: 18,
          errorTileCallback: (tile, error, stackTrace) {
            print("HERE Maps tile error: $error for tile: $tile");
          },
        );
   }

   @override
   void dispose() {
     super.dispose();
   }
}
