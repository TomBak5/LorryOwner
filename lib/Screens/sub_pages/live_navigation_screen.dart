import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart'; // Removed - now using HERE Maps API
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/api_config.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import 'package:http/http.dart' as http; // Added for http package

/// Result class for Flexible Polyline decoding
class _FlexiblePolylineHeader {
  final int precision2d;
  final int type3d;
  
  _FlexiblePolylineHeader(this.precision2d, this.type3d);
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
  MapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _isNavigating = false;
  bool _isMapReady = false; // Add flag to track map readiness

  String _distanceToDestination = "";
  String _timeToDestination = "";
  String _nextManeuver = "";
  String _currentSpeed = "0 km/h";
  
  // Error handling variables
  String? _lastError;
  bool _shouldShowErrorDialog = false;
  
  List<LatLng> _routePoints = [];
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  LatLng? _currentLocation;
  
  // Add address variables
  String _pickupAddress = "Loading address...";
  String _dropoffAddress = "Loading address...";
  
  // Fake movement simulation variables
  int _fakeRouteIndex = 0;
  Timer? _fakeMovementTimer;
  bool _isSimulatingMovement = false;
  String _fakeCurrentSpeed = "0 km/h";
  
  /// Safely gets the map controller, creating one if needed
  MapController _getMapController() {
    if (_mapController == null) {
      print('⚠️ Map controller was null, creating new one');
      _mapController = MapController();
    }
    
    // Double-check that the controller is valid
    if (_mapController == null) {
      print('❌ Failed to create map controller, creating emergency fallback');
      _mapController = MapController();
    }
    
    return _mapController!;
  }

  /// Safely checks if the map is ready and accessible
  bool _isMapAccessible() {
    return _isMapReady && _mapController != null && _mapController!.camera.zoom != null;
  }

  /// Shows an error dialog to the user
  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    
    setState(() {
      _lastError = message;
      _shouldShowErrorDialog = true;
    });
    
    // Auto-hide error after 5 seconds if user doesn't dismiss it
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _shouldShowErrorDialog) {
        setState(() {
          _shouldShowErrorDialog = false;
        });
      }
    });
  }

  /// Dismisses the error dialog
  void _dismissErrorDialog() {
    if (mounted) {
      setState(() {
        _shouldShowErrorDialog = false;
        _lastError = null;
      });
    }
  }
  
  /// Advances to the next navigation instruction
  void _nextTurn() {
    if (_routePoints.length < 2) {
      print('⚠️ No route points available for navigation');
      return;
    }
    
    setState(() {
      _fakeRouteIndex++;
      
      // Update current location to next route point
      if (_fakeRouteIndex < _routePoints.length) {
        _currentLocation = _routePoints[_fakeRouteIndex];
      }
      
      // Update navigation info
      _updateNavigationInfo();
    });
    
    print('🔄 Advanced to turn $_fakeRouteIndex');
    
    // Fit map to show current position
    if (_currentLocation != null) {
      _fitMapToCurrentLocation();
    }
  }
  
  /// Updates navigation info for current position
  void _updateNavigationInfo() {
    if (_fakeRouteIndex >= _routePoints.length - 1) {
      setState(() {
        _nextManeuver = "You have arrived at your destination";
        _distanceToDestination = "0.0 km";
        _timeToDestination = "0 min";
      });
      return;
    }
    
    // Calculate remaining distance
    double remainingDistance = 0;
    for (int i = _fakeRouteIndex; i < _routePoints.length - 1; i++) {
      remainingDistance += _calculateDistance(
        _routePoints[i].latitude, _routePoints[i].longitude,
        _routePoints[i + 1].latitude, _routePoints[i + 1].longitude
      );
    }
    
    // Calculate remaining time (assuming average speed of 45 km/h)
    final remainingTimeMinutes = (remainingDistance / 45.0) * 60;
    
    setState(() {
      _distanceToDestination = '${remainingDistance.toStringAsFixed(1)} km';
      _timeToDestination = '${remainingTimeMinutes.round()} min';
      
      // Generate fake turn-by-turn navigation
      _nextManeuver = _generateFakeManeuver();
    });
    
    print('📊 Updated navigation info:');
    print('   • Distance remaining: $_distanceToDestination');
    print('   • Time remaining: $_timeToDestination');
    print('   • Next maneuver: $_nextManeuver');
  }
  
  /// Generates fake turn-by-turn navigation messages
  String _generateFakeManeuver() {
    if (_fakeRouteIndex >= _routePoints.length - 1) {
      return "You have arrived at your destination";
    }
    
    final random = math.Random();
    final maneuvers = [
      "Continue straight ahead",
      "Turn right in 200m",
      "Turn left in 150m",
      "Keep right",
      "Merge onto highway",
      "Take exit 3",
      "Follow signs for city center",
      "Stay in left lane",
      "Roundabout ahead - take 2nd exit",
      "Traffic light ahead",
      "Speed limit 50 km/h",
      "Sharp turn ahead",
      "Bridge crossing",
      "Tunnel ahead",
      "Rest area in 2 km"
    ];
    
    return maneuvers[random.nextInt(maneuvers.length)];
  }
  
  /// Fits map to show current fake truck location
  void _fitMapToCurrentLocation() {
    if (_currentLocation == null || !_isMapAccessible()) return;
    
    try {
      _getMapController().move(_currentLocation!, 15.0); // Zoom level 15
      print('🗺️ Map moved to fake truck location');
    } catch (e) {
      print('❌ Error moving map to fake truck location: $e');
    }
  }

  /// Converts coordinates to readable addresses using HERE Geocoding API
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = 'https://revgeocode.search.hereapi.com/v1/revgeocode?at=${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}&apiKey=${ApiConfig.hereMapsApiKey}';
      
      print('🌍 Geocoding coordinates: $lat, $lng');
      print('🔗 URL: $url');
      
      // Use http package for simple GET request
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          final address = item['address'];
          
          if (address != null) {
            // Build a readable address
            final parts = <String>[];
            
            if (address['street'] != null) parts.add(address['street']);
            if (address['houseNumber'] != null) parts.add(address['houseNumber']);
            if (address['city'] != null) parts.add(address['city']);
            if (address['state'] != null) parts.add(address['state']);
            if (address['countryCode'] != null) parts.add(address['countryCode']);
            
            final readableAddress = parts.join(', ');
            print('📍 Geocoded address: $readableAddress');
            return readableAddress.isNotEmpty ? readableAddress : 'Address not found';
          }
        }
      }
      
      print('⚠️ Could not geocode coordinates, using fallback');
      _showErrorDialog(
        'Geocoding Warning',
        'Could not get address for coordinates. Using coordinates instead.',
      );
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      
    } catch (e) {
      print('❌ Geocoding error: $e');
      _showErrorDialog(
        'Geocoding Error',
        'Failed to get address: ${e.toString()}. Using coordinates instead.',
      );
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }
  
       @override
  void initState() {
    super.initState();
    
    // Initialize map controller
    _mapController = MapController();
    
    // Ensure controller is properly initialized
    if (_mapController != null) {
      print('🗺️ Map controller initialized successfully');
    } else {
      print('❌ Failed to initialize map controller');
    }
     
     print('LiveNavigationScreen initState called');
     print('📍 Pickup coordinates: ${widget.pickupLat}, ${widget.pickupLng}');
     print('🎯 Dropoff coordinates: ${widget.dropoffLat}, ${widget.dropoffLng}');
     print('🗺️ Map will center on: ${widget.pickupLat}, ${widget.pickupLng}');
     print('🗺️ Map controller created: ${_mapController != null}');
     print('🔑 HERE API Key: ${ApiConfig.hereMapsApiKey}');
     print('🔑 API Key length: ${ApiConfig.hereMapsApiKey.length}');
     print('🔑 API Key empty: ${ApiConfig.hereMapsApiKey.isEmpty}');
    
    _initializeNavigation();
    
    // Remove auto-start navigation - let user manually start navigation by pressing "Confirm & Go"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(
            fontFamily: fontFamilyBold,
            color: Colors.white,
          ),
        ),
        backgroundColor: priMaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [],
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
      color: Colors.white,
      child: Column(
        children: [
          // Header title
          Row(
            children: [
                             Text(
                 'New Delivery',
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.w500,
                   color: Colors.black,
                   fontFamily: 'Poppins',
                 ),
               ),
              const Spacer(),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Show different content based on navigation state
          if (!_isNavigating) ...[
            // Distance section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_timeToDestination} (${_distanceToDestination}) total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pickup address section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pick up address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _pickupAddress,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dropoff address section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Drop off address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dropoffAddress,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Navigation mode - show current speed and navigation info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Current Speed
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.speed,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Speed',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentSpeed,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigation Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.navigation,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Navigation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _nextManeuver.isNotEmpty ? _nextManeuver : 'Following route...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ], // Close the else block
          
          const SizedBox(height: 20),
          
          // Confirm & Go button
          if (_routePoints.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isNavigating = true;
                    _fakeRouteIndex = 0;
                    _currentLocation = _routePoints.first;
                    _updateNavigationInfo();
                  });
                  print('🚛 Navigation started manually');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm & Go',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamilyBold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Next Turn button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isNavigating ? _nextTurn : null,
                icon: const Icon(Icons.navigation, size: 18),
                label: const Text('Next Turn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _stopNavigation,
          icon: const Icon(Icons.stop, size: 18),
          label: const Text('Stop Navigation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    try {
      print('🗺️ Building map view...');
      print('📍 Pickup location: $_pickupLocation');
      print('📍 Dropoff location: $_dropoffLocation');
      print('📍 Current location: $_currentLocation');
      
      // Safety check: ensure map controller is available
      if (_mapController == null) {
        print('⚠️ Map controller not available yet, showing loading...');
        // Try to create a new controller
        _mapController = MapController();
      }
      
      return Container(
        margin: const EdgeInsets.all(8),
        height: 400, // Add fixed height to ensure map has dimensions
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.blue[50], // Add background color for debugging
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Debug info overlay
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Map Debug: ${_isMapReady ? "Ready" : "Loading..."}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      // Addresses are now shown below with bold styling
                      SizedBox(height: 4),
                      Text(
                        'Pickup: $_pickupAddress',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dropoff: $_dropoffAddress',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Map Center: ${_isMapAccessible() && _getMapController().camera.center != null ? '${_getMapController().camera.center!.latitude.toStringAsFixed(6)}, ${_getMapController().camera.center!.longitude.toStringAsFixed(6)}' : 'Loading...'}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              // Map status indicator
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Map Status: ${_isMapReady ? "Ready" : "Loading"}',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Zoom: ${_isMapAccessible() ? _getMapController().camera.zoom.toStringAsFixed(1) : "N/A"}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              // Simple test widget to verify map container
              Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Container: ${MediaQuery.of(context).size.width}x${MediaQuery.of(context).size.height}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
              // Test if map is actually rendering
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Map Status:',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ready: $_isMapReady',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      Text(
                        'Controller: ${_mapController != null ? "OK" : "NULL"}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      Text(
                        'Camera: ${_isMapAccessible() ? "OK" : "Loading"}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              // Error Dialog Overlay
              if (_shouldShowErrorDialog && _lastError != null)
                Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _lastError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _dismissErrorDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Fallback message if map fails
            if (!_isMapReady)
              Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Map Loading...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'If this persists, check internet connection',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              // Fallback message if map fails
              if (!_isMapReady)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Map Loading...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'If this persists, check internet connection',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              FlutterMap(
                mapController: _getMapController(),
                options: MapOptions(
                  initialCenter: LatLng(widget.pickupLat, widget.pickupLng),
                  initialZoom: 12,
                  onMapReady: _onMapReady,
                  onMapEvent: (MapEvent event) {
                    print('🗺️ Map event: ${event.runtimeType}');
                  },
                ),
                children: [
                  // Use the _buildMapTiles() method for consistent tile configuration
                  _buildMapTiles(),
                  
                  // Fallback to OpenStreetMap if HERE tiles fail
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.moverslorryowner.app',
                    maxZoom: 18,
                    minZoom: 1,
                    // This layer will only show if HERE tiles fail
                    fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  
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
                     // Pickup marker - always show using widget coordinates
                     Marker(
                       point: LatLng(widget.pickupLat, widget.pickupLng),
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
                     
                     // Dropoff marker - always show using widget coordinates
                     Marker(
                       point: LatLng(widget.dropoffLat, widget.dropoffLng),
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
          ],
        ),
      ),
    );
    } catch (e, stackTrace) {
      print('❌ Error building map view: $e');
      print('📚 Stack trace: $stackTrace');
      
      // Return a fallback widget on error
      return Container(
        margin: const EdgeInsets.all(8),
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[300]!),
          color: Colors.red[50],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text('Map Error', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Please try again or restart the app'),
            ],
          ),
        ),
      );
    }
  }

  // Callback when map is ready
  void _onMapReady() {
    print('��️ Map is ready!');
    setState(() {
      _isMapReady = true;
    });
    
    // Ensure map controller is properly initialized
    if (!_isMapAccessible()) {
      print('⚠️ Map controller camera not fully initialized, waiting...');
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
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
      
      _startLocationUpdates();
    } catch (e) {
      print('Error getting current location: $e');
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
    
    // Geocode coordinates to get readable addresses
    print('🌍 Geocoding pickup and dropoff addresses...');
    final pickupAddress = await _getAddressFromCoordinates(widget.pickupLat, widget.pickupLng);
    final dropoffAddress = await _getAddressFromCoordinates(widget.dropoffLat, widget.dropoffLng);
    
    setState(() {
      _pickupAddress = pickupAddress;
      _dropoffAddress = dropoffAddress;
    });
    
    print('📍 Pickup address: $_pickupAddress');
    print('🎯 Dropoff address: $_dropoffAddress');
    
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
          final sections = routeResult['route']['sections'] as List;
          for (int i = 0; i < sections.length; i++) {
            final section = sections[i];
            print('   • Section $i Keys: ${section.keys.toList()}');
            if (section['polyline'] != null) {
              print('     - Polyline Type: ${section['polyline'].runtimeType}');
              print('     - Polyline Preview: ${section['polyline'].toString().substring(0, 100)}...');
            }
            if (section['shape'] != null) {
              print('     - Shape Type: ${section['shape'].runtimeType}');
              print('     - Shape Preview: ${section['shape'].toString().substring(0, 100)}...');
            }
          }
        }
      }
      print('   • Has Polyline: ${routeResult['polyline'] != null ? 'Yes' : 'No'}');
      if (routeResult['polyline'] != null) {
        print('   • Polyline Type: ${routeResult['polyline'].runtimeType}');
        print('   • Polyline Content: ${routeResult['polyline']}');
      }
      
      // Also check for other possible route data formats
      print('   • All available keys: ${routeResult.keys.toList()}');
      print('   • Response type: ${routeResult.runtimeType}');
      print('');
      
      if (routeResult['success'] == true) {
        print('✅ Route calculated successfully using API provider');
        
                 // Update route info from API response
         setState(() {
           _distanceToDestination = routeResult['distance'] ?? 'N/A';
           _timeToDestination = routeResult['duration'] ?? 'N/A';
         });
         
         print('📊 Route Info Updated:');
         print('   • Distance: $_distanceToDestination');
         print('   • Time: $_timeToDestination');
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
        
        // If still no points, try to extract from the raw route data
        if (_routePoints.isEmpty) {
          print('🔄 No shape data either, trying to extract from raw route data...');
          _routePoints = _extractFromRawRouteData(route);
          if (_routePoints.isNotEmpty) {
            print('📍 Extracted ${_routePoints.length} points from raw route data');
          }
        }
      }
                    } else {
           print('⚠️ No sections found in route data');
           print('🔄 No route data available - will show direct line only');
           _routePoints = []; // No fallback route - just show pickup and dropoff
         }
         } else if (routeResult['polyline'] != null) {
           print('🔗 No route data, but found polyline - parsing...');
           
           // Check if polyline is already decoded coordinates or encoded string
           if (routeResult['polyline'] is List) {
             print('📍 Polyline is already List<LatLng> - using directly');
             _routePoints = List<LatLng>.from(routeResult['polyline']);
             print('📍 Using ${_routePoints.length} pre-decoded coordinates from polyline');
           } else {
             print('📍 Polyline is encoded string - decoding...');
             _routePoints = _parsePolylineToRoutePoints(routeResult['polyline']);
             print('📍 Parsed ${_routePoints.length} REAL route points from polyline');
           }
         } else {
           print('⚠️ No route or polyline data available from HERE API');
           print('🔄 No route data available - will show direct line only');
           print('💡 This usually means the HERE Maps API response was empty or malformed');
           _routePoints = []; // No fallback route - just show pickup and dropoff
         }
        
        print('🗺️ Route Points Summary:');
        print('   • Total Points: ${_routePoints.length}');
        if (_routePoints.isNotEmpty) {
          print('   • Start: ${_routePoints.first.latitude}, ${_routePoints.first.longitude}');
          print('   • End: ${_routePoints.last.latitude}, ${_routePoints.last.longitude}');
          
          // Check if coordinates look realistic
          final firstPoint = _routePoints.first;
          final lastPoint = _routePoints.last;
          final expectedStart = LatLng(widget.pickupLat, widget.pickupLng);
          final expectedEnd = LatLng(widget.dropoffLat, widget.dropoffLng);
          
          print('   • Expected Start: ${expectedStart.latitude}, ${expectedStart.longitude}');
          print('   • Expected End: ${expectedEnd.latitude}, ${expectedEnd.longitude}');
          
          // Check if we're using real or fake coordinates
          if (_routePoints.length > 2) {
            print('   • Route Type: ${_routePoints.length} points from HERE API');
            
            // Check if coordinates are realistic (not tiny increments)
            bool hasRealisticCoordinates = true;
            for (int i = 0; i < _routePoints.length; i++) {
              final point = _routePoints[i];
              if (point.latitude.abs() < 0.001 || point.longitude.abs() < 0.001) {
                print('   ⚠️ Point $i has suspicious coordinates: ${point.latitude}, ${point.longitude}');
                hasRealisticCoordinates = false;
              }
            }
            
            if (hasRealisticCoordinates) {
              print('   • ✅ Coordinates look realistic (real road data)');
            } else {
              print('   • ❌ Coordinates look suspicious (tiny increments)');
              print('   • This explains the scribbled appearance!');
            }
          } else if (_routePoints.length == 2) {
            print('   • Route Type: Simple direct line (pickup to dropoff) 📍');
            print('   • This is clean and straight - no scribbles');
          }
        } else {
          print('   • Route Type: No route data available ⚠️');
          print('   • Creating simple direct line to avoid scribbles');
          // Create a simple direct line between pickup and dropoff
          _routePoints = [
            LatLng(widget.pickupLat, widget.pickupLng),
            LatLng(widget.dropoffLat, widget.dropoffLng),
          ];
          print('📍 Created simple direct line with ${_routePoints.length} points');
        }
        
        // Initialize route points but DON'T start navigation automatically
        if (_routePoints.isNotEmpty) {
          setState(() {
            _fakeRouteIndex = 0;
            _currentLocation = _routePoints.first;
            // Don't set _isNavigating = true here - let user press "Confirm & Go" first
          });
          print('🚛 Route points initialized - waiting for user to press "Confirm & Go"');
        }
        print('');
        
        // Fit map to route
        print('🗺️ Fitting map to route...');
        _fitMapToRoute();
        
             } else {
         print('❌ Route calculation failed: ${routeResult['message']}');
         _showErrorDialog(
           'Route Calculation Failed',
           'Failed to calculate route: ${routeResult['message']}. No route will be displayed.',
         );
         print('🔄 No fallback route created - will show direct line only');
         _routePoints = []; // No fallback route
       }
      
      print('🚛 ====== HERE API ROUTE CALCULATION END ======');
      print('');
      
         } catch (e) {
       print('💥 ====== ERROR IN ROUTE CALCULATION ======');
       print('❌ Error getting route from API provider: $e');
       _showErrorDialog(
         'Route Calculation Error',
         'Failed to calculate route: ${e.toString()}. No route will be displayed.',
       );
       print('🔄 No fallback route created - will show direct line only');
       _routePoints = []; // No fallback route
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
      _showErrorDialog(
        'Route Parsing Error',
        'Failed to parse route data: ${e.toString()}. No route will be displayed.',
      );
      print('🔄 No fallback route created');
      print('💥 ====== POLYLINE PARSING ERROR END ======');
      print('');
      return []; // Return empty list instead of fallback route
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
        print('⚠️ No route points extracted from sections');
        return []; // Return empty list instead of fallback
      }
    } catch (e) {
      print('❌ Error extracting route shape from sections: $e');
      return []; // Return empty list instead of fallback
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

  /// Tries to extract route points from raw route data in any format
  List<LatLng> _extractFromRawRouteData(Map<String, dynamic> route) {
    print('🔍 Trying to extract route points from raw route data...');
    print('📝 Route keys: ${route.keys.toList()}');
    
    final List<LatLng> points = [];
    
    try {
      // Try different possible data structures
      if (route['geometry'] != null) {
        print('📍 Found geometry data');
        return _parsePolylineToRoutePoints(route['geometry']);
      }
      
      if (route['coordinates'] != null) {
        print('📍 Found coordinates data');
        return _parsePolylineToRoutePoints(route['coordinates']);
      }
      
      if (route['points'] != null) {
        print('📍 Found points data');
        return _parsePolylineToRoutePoints(route['points']);
      }
      
      if (route['path'] != null) {
        print('📍 Found path data');
        return _parsePolylineToRoutePoints(route['path']);
      }
      
      // Try to find any array that might contain coordinates
      for (String key in route.keys) {
        final value = route[key];
        if (value is List && value.isNotEmpty) {
          print('🔍 Checking key "$key" with ${value.length} items...');
          if (value.first is Map && (value.first['lat'] != null || value.first['latitude'] != null)) {
            print('📍 Found coordinate array in key "$key"');
            return _parsePolylineToRoutePoints(value);
          }
        }
      }
      
      print('⚠️ No recognizable route data found in raw route');
      return [];
      
    } catch (e) {
      print('❌ Error extracting from raw route data: $e');
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
  /// Based on official HERE Maps documentation: https://github.com/heremaps/flexible-polyline
  List<LatLng> _decodeHerePolyline(String encodedPolyline) {
    print('🔐 Decoding HERE Flexible Polyline: ${encodedPolyline.length} characters');
    print('📝 Polyline preview: ${encodedPolyline.length > 100 ? '${encodedPolyline.substring(0, 100)}...' : encodedPolyline}');
    
    try {
      // Check minimum length (need at least 2 header characters)
      if (encodedPolyline.length < 2) {
        print('❌ Polyline too short: ${encodedPolyline.length} characters');
        return [];
      }
      
      // Decode header according to HERE Maps specification
      final headerResult = _decodeFlexiblePolylineHeader(encodedPolyline);
      if (headerResult == null) {
        print('❌ Failed to decode polyline header');
        return [];
      }
      
      print('   📊 Header decoded: precision=${headerResult.precision2d}, type3d=${headerResult.type3d}');
      
      // Decode all coordinate deltas
      final deltas = _decodeFlexiblePolylineDeltas(encodedPolyline.substring(2));
      if (deltas.isEmpty) {
        print('❌ No coordinate deltas decoded');
        return [];
      }
      
      print('   📍 Decoded ${deltas.length} coordinate deltas');
      
      // Convert deltas to absolute coordinates
      final List<LatLng> points = [];
      double lat = 0.0;
      double lng = 0.0;
      
      // Process deltas in pairs (lat, lng)
      for (int i = 0; i < deltas.length; i += 2) {
        if (i + 1 < deltas.length) {
          // Convert delta to coordinate using precision from header
          lat += deltas[i] / math.pow(10, headerResult.precision2d);
          lng += deltas[i + 1] / math.pow(10, headerResult.precision2d);
          
          points.add(LatLng(lat, lng));
          
          // Debug first few points
          if (points.length <= 5) {
            print('     📍 Point ${points.length}: $lat, $lng (delta: ${deltas[i]}, ${deltas[i + 1]})');
          }
        }
      }
      
      if (points.isNotEmpty) {
        print('✅ Successfully decoded ${points.length} REAL route points from HERE Flexible Polyline');
        print('   • First point: ${points.first.latitude}, ${points.first.longitude}');
        print('   • Last point: ${points.last.latitude}, ${points.last.longitude}');
        
        // Check if coordinates look realistic (not tiny values)
        bool hasRealisticCoordinates = true;
        for (int i = 0; i < points.length; i++) {
          final point = points[i];
          if (point.latitude.abs() < 0.001 || point.longitude.abs() < 0.001) {
            print('   ⚠️ Point $i has suspicious coordinates: ${point.latitude}, ${point.longitude}');
            hasRealisticCoordinates = false;
          }
        }
        
        if (hasRealisticCoordinates) {
          print('   ✅ Coordinates look realistic (real road data)');
        } else {
          print('   ❌ Coordinates look suspicious (tiny values)');
        }
        
        return points;
      } else {
        print('⚠️ No points decoded from Flexible Polyline');
        return [];
      }
      
    } catch (e) {
      print('❌ Error decoding HERE Flexible Polyline: $e');
      print('📝 Polyline string: $encodedPolyline');
      return [];
    }
  }
  
  /// Decodes the header of a Flexible Polyline according to HERE Maps specification
  _FlexiblePolylineHeader? _decodeFlexiblePolylineHeader(String encodedPolyline) {
    try {
      // First character: version (should be 1 for current format)
      final version = _decodeFlexiblePolylineChar(encodedPolyline[0]);
      if (version != 1) {
        print('⚠️ Unexpected polyline version: $version (expected 1)');
      }
      
      // Second character: precision and 3D info
      final headerContent = _decodeFlexiblePolylineChar(encodedPolyline[1]);
      
      // Extract precision and 3D info according to spec
      final precision2d = headerContent & 0xF;
      final type3d = (headerContent >> 4) & 0x7;
      
      print('   📊 Header: version=$version, precision2d=$precision2d, type3d=$type3d');
      
      return _FlexiblePolylineHeader(precision2d, type3d);
      
    } catch (e) {
      print('❌ Error decoding polyline header: $e');
      return null;
    }
  }
  
  /// Decodes all coordinate deltas from the polyline
  List<int> _decodeFlexiblePolylineDeltas(String encodedDeltas) {
    final List<int> deltas = [];
    int index = 0;
    
    while (index < encodedDeltas.length) {
      int value = 0;
      int shift = 0;
      
      // Decode varint (variable-length integer)
      do {
        if (index >= encodedDeltas.length) break;
        
        final chunk = _decodeFlexiblePolylineChar(encodedDeltas[index++]);
        final isLastChunk = (chunk & 0x20) == 0;
        final chunkValue = chunk & 0x1F;
        
        value |= (chunkValue << shift);
        shift += 5;
        
        if (isLastChunk) {
          // Convert to signed integer
          if ((value & 1) == 1) {
            // Negative value
            value = -((value + 1) >> 1);
          } else {
            // Positive value
            value = value >> 1;
          }
          
          deltas.add(value);
          break;
        }
      } while (true);
    }
    
    return deltas;
  }
  
  /// Decodes a single character from Flexible Polyline character set
  int _decodeFlexiblePolylineChar(String char) {
    // According to HERE Maps spec, characters A-Z, a-z, 0-9, -, _ are used
    // A=0, B=1, ..., Z=25, a=26, ..., z=51, 0=52, ..., 9=61, -=62, _=63
    final code = char.codeUnitAt(0);
    
    if (code >= 65 && code <= 90) { // A-Z
      return code - 65;
    } else if (code >= 97 && code <= 122) { // a-z
      return code - 97 + 26;
    } else if (code >= 48 && code <= 57) { // 0-9
      return code - 48 + 52;
    } else if (char == '-') {
      return 62;
    } else if (char == '_') {
      return 63;
    } else {
      print('⚠️ Unknown polyline character: $char (code: $code)');
      return 0;
    }
  }
  
  List<LatLng> _createIntermediateRoutePoints() {
    print('🔄 ====== INTERMEDIATE ROUTE POINTS CREATION ======');
    print('📍 Pickup: ${widget.pickupLat}, ${widget.pickupLng}');
    print('🎯 Dropoff: ${widget.dropoffLat}, ${widget.dropoffLng}');
    print('');
    
    // Create a simple direct line - no curves, no scribbles!
    
    final List<LatLng> points = [
      LatLng(widget.pickupLat, widget.pickupLng),
      LatLng(widget.dropoffLat, widget.dropoffLng),
    ];
    
    final double directDistance = _calculateDistance(
      widget.pickupLat, widget.pickupLng,
      widget.dropoffLat, widget.dropoffLng
    );
    
    print('✅ Created simple direct line with ${points.length} points for ${directDistance.toStringAsFixed(2)} km journey');
    print('💡 This is a clean straight line - no scribbles!');
    print('🔄 ====== INTERMEDIATE ROUTE POINTS CREATION END ======');
    print('');
    
    // Calculate route info using the points
    _calculateRouteInfoWithPoints(points);
    
    return points;
  }
  
  /// Creates a simple direct line between pickup and dropoff (no scribbles)
  List<LatLng> _createSimpleDirectLine() {
    print('📍 ====== SIMPLE DIRECT LINE CREATION ======');
    
    final List<LatLng> points = [
      LatLng(widget.pickupLat, widget.pickupLng),
      LatLng(widget.dropoffLat, widget.dropoffLng),
    ];
    
    final double directDistance = _calculateDistance(
      widget.pickupLat, widget.pickupLng,
      widget.dropoffLat, widget.dropoffLng
    );
    
    print('✅ Created simple direct line with ${points.length} points for ${directDistance.toStringAsFixed(2)} km journey');
    print('💡 This is a clean straight line - no scribbles!');
    print('📍 ====== SIMPLE DIRECT LINE CREATION END ======');
    
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
       });
       
       print('📊 Route Info Updated:');
       print('   • Distance: $_distanceToDestination');
       print('   • Time: $_timeToDestination');
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
    // Create simple direct line instead of complex route
    _routePoints = [
      LatLng(widget.pickupLat, widget.pickupLng),
      LatLng(widget.dropoffLat, widget.dropoffLng),
    ];
    
    // Calculate simple route info
    _calculateRouteInfo();
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

  String _calculateETAFromDuration(String duration) {
    try {
      // Parse duration string like "45 min" to get minutes
      final match = RegExp(r'(\d+)').firstMatch(duration);
      if (match != null) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        return '${minutes.toString().padLeft(2, '0')}:00'; // Assuming ETA is in HH:MM format
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
        if (_isMapAccessible()) {
          final bounds = LatLngBounds.fromPoints(_routePoints);
          _getMapController().fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
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
        _showErrorDialog(
          'Map Error',
          'Failed to fit map to route: ${e.toString()}.',
        );
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



     /// Builds map tiles using HERE Maps with fallback to OpenStreetMap
   Widget _buildMapTiles() {
        print('🗺️ Building map tiles...');
        print('🔑 HERE API Key: ${ApiConfig.hereMapsApiKey}');
        print('🔑 API Key length: ${ApiConfig.hereMapsApiKey.length}');
        
        // Use HERE Maps raster tiles with alternative format
        return TileLayer(
          urlTemplate: 'https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png8?style=satellite.day&apiKey=${ApiConfig.hereMapsApiKey}',
          userAgentPackageName: 'com.moverslorryowner.app',
          maxZoom: 18,
          minZoom: 1,
          errorTileCallback: (tile, error, stackTrace) {
            print("🚨 HERE Maps tile error: $error");
            print("🔑 API Key used: ${ApiConfig.hereMapsApiKey}");
            print("🌐 Full URL: https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png8?style=satellite.day&apiKey=${ApiConfig.hereMapsApiKey}");
            print("📚 Stack trace: $stackTrace");
          },
          // Add tile loading callbacks for debugging
          tileBuilder: (context, child, tile) {
            print("✅ Tile loaded successfully");
            return child;
          },
        );
   }

   @override
   void dispose() {
     if (_mapController != null) {
       _mapController!.dispose();
       _mapController = null;
     }
     super.dispose();
   }
}
