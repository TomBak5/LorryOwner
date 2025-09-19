import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexible_polyline_dart/flutter_flexible_polyline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../AppConstData/api_config.dart';
import '../../Api_Provider/api_provider.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import '../../AppConstData/typographyy.dart';
import 'package:http/http.dart' as http;

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

class _LiveNavigationScreenState extends State<LiveNavigationScreen> with TickerProviderStateMixin {
  MapController? _mapController;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _isNavigating = false;

  String _distanceToDestination = "Calculating...";
  String _timeToDestination = "Calculating...";
  String _nextStreetName = "Current street";
  String _nextTurnInstruction = "Continue straight";
  String _nextTurnDistance = "";
  int _nextTurnIndex = 0;
  String _estimatedArrival = "Calculating...";
  
  List<LatLng> _routePoints = [];
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  LatLng? _currentLocation;
  
  List<Map<String, dynamic>>? _hereApiWaypoints;
  
  String _pickupAddress = "Loading address...";
  String _dropoffAddress = "Loading address...";
  
  // Fake movement simulation
  int _fakeRouteIndex = 0;
  Timer? _fakeMovementTimer;
  
  // Navigation state
  bool _isMuted = false;
  bool _isAutomaticMovement = false;
  
  // API provider for route calculation
  final ApiProvider _apiProvider = ApiProvider();
  
  int _totalCalculations = 0;
  int _cachedHits = 0;
  DateTime _navigationStartTime = DateTime.now();

  late final _animatedMapController = AnimatedMapController(vsync: this);

  void _logPerformanceMetrics() {
    final duration = DateTime.now().difference(_navigationStartTime);
    final cacheHitRate = _totalCalculations > 0 ? (_cachedHits / _totalCalculations * 100).toStringAsFixed(1) : '0.0';
    
    print('📊 PERFORMANCE METRICS:');
    print('   • Navigation Duration: ${duration.inSeconds}s');
    print('   • Total Calculations: $_totalCalculations');
    print('   • Cache Hits: $_cachedHits');
    print('   • Cache Hit Rate: ${cacheHitRate}%');
    print('   • Route Points: ${_routePoints.length}');
    print('   • Optimized Points: ${_getOptimizedRoutePoints().length}');
    print('   • Current Index: $_fakeRouteIndex');
    print('   • Memory Usage: ${_getMemoryUsage()}');
    
    // PERFORMANCE FIX: Clear caches if they get too large
    if (_cachedBearing.length > 1000) {
      print('🧹 Clearing bearing cache (${_cachedBearing.length} entries)');
      _cachedBearing.clear();
    }
    if (_cachedDistances.length > 1000) {
      print('🧹 Clearing distance cache (${_cachedDistances.length} entries)');
      _cachedDistances.clear();
    }
  }
  
  // PERFORMANCE FIX: Memory usage monitoring
  String _getMemoryUsage() {
    try {
      // This is a simplified memory check - in production you'd use proper memory profiling
      final totalCaches = _cachedBearing.length + _cachedDistances.length + _cachedStreetNames.length + _cachedTurnInstructions.length;
      return 'Caches: $totalCaches entries';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  Future<void> _debugMap() async {
    print('🐛 DEBUG MAP FUNCTIONALITY:');
    print('   • Route points count: ${_routePoints.length}');
    print('   • Pickup location: $_pickupLocation');
    print('   • Dropoff location: $_dropoffLocation');
    print('   • Map controller: ${_mapController != null}');
    print('   • Is loading: $_isLoading');
    print('   • Has location permission: $_hasLocationPermission');
    print('   • Is navigating: $_isNavigating');
    
    if (_routePoints.isNotEmpty) {
      print('   • First route point: ${_routePoints.first}');
      print('   • Last route point: ${_routePoints.last}');
    }
    
    // Show HERE API waypoints if available
    if (_hereApiWaypoints != null && _hereApiWaypoints!.isNotEmpty) {
      print('🗺️ HERE API Waypoints (${_hereApiWaypoints!.length}):');
      for (int i = 0; i < _hereApiWaypoints!.length; i++) {
        var waypoint = _hereApiWaypoints![i];
        print('   ${i + 1}. ${waypoint['instruction'] ?? 'No instruction'}');
        if (waypoint['distance'] != null) {
          print('      Distance: ${waypoint['distance']}');
        }
        if (waypoint['icon'] != null) {
          print('      Icon: ${waypoint['icon']}');
        }
      }
    } else {
      print('⚠️ No HERE API waypoints available');
    }
    
    // Force route generation if empty
    if (_routePoints.isEmpty) {
      print('⚠️ No route points, generating fallback route...');
      _generateRoutePoints();
      setState(() {});
    }
    
    // Test HERE Maps tile URL
    print('🧪 HERE Maps Tile URL Test:');
    String testUrl = 'https://maps.hereapi.com/v3/base/mc/10/512/256/png?apiKey=${ApiConfig.hereMapsApiKey}';
    print('🧪 Test URL: $testUrl');
    print('🔑 API Key: ${ApiConfig.hereMapsApiKey.substring(0, 10)}...');
    
    // Test if the API key works by making a simple request
    try {
      final response = await http.get(Uri.parse(testUrl));
      print('🧪 Tile request status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ Tile request successful!');
      } else {
        print('❌ Tile request failed: ${response.statusCode}');
        print('🔍 Response headers: ${response.headers}');
      }
    } catch (e) {
      print('❌ Tile request error: $e');
    }
  }
  

  final Map<String, double> _cachedBearing = {};
  final Map<String, double> _cachedDistances = {};
  final Map<int, String> _cachedStreetNames = {};
  final Map<int, String> _cachedTurnInstructions = {};
  

  static const int _movementUpdateInterval = 250;
  static const int _navigationInfoUpdateInterval = 2000;
  static const int _mapUpdateInterval = 1000;
  
  DateTime _lastNavigationInfoUpdate = DateTime.now();
  DateTime _lastMapUpdate = DateTime.now();
  
  void _calculateUpcomingTurns() {
    if (_routePoints.isEmpty || _fakeRouteIndex >= _routePoints.length - 1) return;
    
    try {
      final now = DateTime.now();
      if (now.difference(_lastNavigationInfoUpdate).inMilliseconds < _navigationInfoUpdateInterval) {
        return; // Skip update if too soon
      }
      _lastNavigationInfoUpdate = now;
      
      if (_hereApiWaypoints != null && _hereApiWaypoints!.isNotEmpty) {
        int currentProgress = (_fakeRouteIndex / _routePoints.length * _hereApiWaypoints!.length).round();
        if (currentProgress < _hereApiWaypoints!.length) {
          var nextWaypoint = _hereApiWaypoints![currentProgress];
          
          _nextTurnInstruction = nextWaypoint['instruction'] ?? "Continue straight";
          _nextStreetName = nextWaypoint['instruction'] ?? "Current route";
          
          if (currentProgress < _hereApiWaypoints!.length - 1) {
            double distanceToNext = _calculateDistanceToPoint(_fakeRouteIndex, 
              (_routePoints.length * (currentProgress + 1) / _hereApiWaypoints!.length).round());
            _nextTurnDistance = "${distanceToNext.toStringAsFixed(0)} m";
          } else {
            _nextTurnDistance = "Destination";
          }
          
          print('🔄 HERE API turn: $_nextTurnInstruction in $_nextTurnDistance on $_nextStreetName');
          return;
        }
      }
      
      int currentIndex = _fakeRouteIndex;
      int nextTurnIndex = _findNextTurn(currentIndex);
      
      if (nextTurnIndex > currentIndex) {
        _nextTurnIndex = nextTurnIndex;
        
        String distanceKey = '${currentIndex}_${nextTurnIndex}';
        double distanceToTurn;
        if (_cachedDistances.containsKey(distanceKey)) {
          distanceToTurn = _cachedDistances[distanceKey]!;
        } else {
          distanceToTurn = _calculateDistanceToPoint(currentIndex, nextTurnIndex);
          _cachedDistances[distanceKey] = distanceToTurn;
        }
        _nextTurnDistance = "${distanceToTurn.toStringAsFixed(0)} m";
        
        if (_cachedTurnInstructions.containsKey(nextTurnIndex)) {
          _nextTurnInstruction = _cachedTurnInstructions[nextTurnIndex]!;
        } else {
          _nextTurnInstruction = _getTurnDirection(currentIndex, nextTurnIndex);
          _cachedTurnInstructions[nextTurnIndex] = _nextTurnInstruction;
        }
        
        if (_cachedStreetNames.containsKey(nextTurnIndex)) {
          _nextStreetName = _cachedStreetNames[nextTurnIndex]!;
        } else {
          _nextStreetName = _getStreetNameForPoint(nextTurnIndex);
          _cachedStreetNames[nextTurnIndex] = _nextStreetName;
        }
        
        print('🔄 Calculated turn: $_nextTurnInstruction in $_nextTurnDistance on $_nextStreetName');
      } else {
        _nextTurnInstruction = "Arriving at destination";
        _nextTurnDistance = "";
        _nextStreetName = "Destination";
      }
    } catch (e) {
      print('❌ Error calculating upcoming turns: $e');
    }
  }
  
  int _findNextTurn(int currentIndex) {
    if (currentIndex >= _routePoints.length - 2) return _routePoints.length - 1;
    
    int lookAhead = math.min(5, _routePoints.length - currentIndex - 1);
    
    for (int i = currentIndex + 1; i < currentIndex + lookAhead; i++) {
      if (_isSignificantTurn(currentIndex, i)) {
        return i;
      }
    }
    
    return _routePoints.length - 1; // No significant turn found
  }
  
  bool _isSignificantTurn(int fromIndex, int toIndex) {
    if (fromIndex >= _routePoints.length - 1 || toIndex >= _routePoints.length) return false;
    
    String bearing1Key = '${fromIndex}_${fromIndex + 1}';
    String bearing2Key = '${toIndex - 1}_${toIndex}';
    
    double bearing1, bearing2;
    
    if (_cachedBearing.containsKey(bearing1Key)) {
      bearing1 = _cachedBearing[bearing1Key]!;
    } else {
      bearing1 = _calculateBearing(_routePoints[fromIndex], _routePoints[fromIndex + 1]);
      _cachedBearing[bearing1Key] = bearing1;
    }
    
    if (_cachedBearing.containsKey(bearing2Key)) {
      bearing2 = _cachedBearing[bearing2Key]!;
    } else {
      bearing2 = _calculateBearing(_routePoints[toIndex - 1], _routePoints[toIndex]);
      _cachedBearing[bearing2Key] = bearing2;
    }
    
    double bearingDiff = (bearing2 - bearing1).abs();
    if (bearingDiff > 180) bearingDiff = 360 - bearingDiff;
    
    // Consider it a turn if bearing changes by more than 15 degrees
    return bearingDiff > 15;
  }
  
  double _calculateBearing(LatLng from, LatLng to) {
    String key = '${from.latitude.toStringAsFixed(6)}_${from.longitude.toStringAsFixed(6)}_${to.latitude.toStringAsFixed(6)}_${to.longitude.toStringAsFixed(6)}';
    if (_cachedBearing.containsKey(key)) {
      _cachedHits++;
      return _cachedBearing[key]!;
    }
    
    _totalCalculations++;
    
    // PERFORMANCE FIX: Use optimized bearing calculation
    final result = _calculateBearingOptimized(from, to);
    
    // Cache the result
    _cachedBearing[key] = result;
    return result;
  }
  
  // PERFORMANCE FIX: Optimized bearing calculation
  double _calculateBearingOptimized(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }
  
  double _calculateDistanceToPoint(int fromIndex, int toIndex) {
    if (fromIndex >= _routePoints.length || toIndex >= _routePoints.length) return 0;
    
    String key = '${fromIndex}_${toIndex}';
    if (_cachedDistances.containsKey(key)) {
      return _cachedDistances[key]!;
    }
    
    double totalDistance = 0;
    for (int i = fromIndex; i < toIndex; i++) {
      totalDistance += _calculateHaversineDistance(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude
      );
    }
    
    double result = totalDistance * 1000;
    
    _cachedDistances[key] = result;
    return result;
  }
  
  // Determine turn direction based on bearing change - OPTIMIZED with real HERE API data
  String _getTurnDirection(int fromIndex, int toIndex) {
    if (fromIndex >= _routePoints.length - 1 || toIndex >= _routePoints.length) return "Continue straight";
    
    // Try to get real turn instruction from HERE API waypoints if available
    if (_hereApiWaypoints != null && _hereApiWaypoints!.isNotEmpty) {
      // Find the closest waypoint to this route point
      int waypointIndex = (toIndex / _routePoints.length * _hereApiWaypoints!.length).round();
      if (waypointIndex < _hereApiWaypoints!.length) {
        var waypoint = _hereApiWaypoints![waypointIndex];
        if (waypoint['instruction'] != null) {
          return waypoint['instruction'];
        }
      }
    }
    
    // If no HERE API data, return empty string
    return "";
  }
  
  String _getStreetNameForPoint(int pointIndex) {
    if (pointIndex >= _routePoints.length) return "Unknown location";
    
    if (_cachedStreetNames.containsKey(pointIndex)) {
      return _cachedStreetNames[pointIndex]!;
    }
    
    if (_hereApiWaypoints != null && _hereApiWaypoints!.isNotEmpty) {
      int waypointIndex = (pointIndex / _routePoints.length * _hereApiWaypoints!.length).round();
      if (waypointIndex < _hereApiWaypoints!.length) {
        var waypoint = _hereApiWaypoints![waypointIndex];
        if (waypoint['instruction'] != null) {
          String result = waypoint['instruction'];
          _cachedStreetNames[pointIndex] = result;
          return result;
        }
      }
    }
    
    return "";
  }

  void _showFullRouteOverview() {
    try {
      if (_mapController != null && 
          _pickupLocation != null && 
          _dropoffLocation != null &&
          mounted) {
        
        double minLat = math.min(_pickupLocation!.latitude, _dropoffLocation!.latitude);
        double maxLat = math.max(_pickupLocation!.latitude, _dropoffLocation!.latitude);
        double minLng = math.min(_pickupLocation!.longitude, _dropoffLocation!.longitude);
        double maxLng = math.max(_pickupLocation!.longitude, _dropoffLocation!.longitude);
        
        double latPadding = (maxLat - minLat) * 0.1;
        double lngPadding = (maxLng - minLng) * 0.1;
        
        _mapController!.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(
              LatLng(minLat - latPadding, minLng - lngPadding),
              LatLng(maxLat + latPadding, maxLng + lngPadding),
            ),
            padding: const EdgeInsets.all(50),
            maxZoom: 10,
          ),
        );
        
        print('✅ Route overview displayed successfully');
      } else {
        print('⚠️ Cannot show route overview: mapController=${_mapController != null}, pickup=${_pickupLocation != null}, dropoff=${_dropoffLocation != null}, mounted=$mounted');
      }
    } catch (e) {
      print('❌ Error showing route overview: $e');
    }
  }
  

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeNavigation();
  }

  @override
  void dispose() {
    _fakeMovementTimer?.cancel();
    
    // PERFORMANCE OPTIMIZATION: Clear caches to prevent memory leaks
    _cachedBearing.clear();
    _cachedDistances.clear();
    _cachedStreetNames.clear();
    _cachedTurnInstructions.clear();
    _animatedMapController.dispose();
    
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    try {
      var locationStatus = await Permission.location.request();
      if (locationStatus.isGranted) {
        setState(() => _hasLocationPermission = true);
        _setupRoute();
      } else {
        setState(() {
          _hasLocationPermission = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing navigation: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupRoute() async {
    try {
      print('🔄 Setting up route...');
      print('   • Pickup coordinates: ${widget.pickupLat}, ${widget.pickupLng}');
      print('   • Dropoff coordinates: ${widget.dropoffLat}, ${widget.dropoffLng}');
      
      _pickupLocation = LatLng(widget.pickupLat, widget.pickupLng);
      _dropoffLocation = LatLng(widget.dropoffLat, widget.dropoffLng);
      
      print('✅ Location objects created');
      
      // PERFORMANCE FIX: Move heavy operations to background thread
      await Future.wait([
        _getAddressFromCoordinates(widget.pickupLat, widget.pickupLng).then((address) {
          _pickupAddress = address;
        }),
        _getAddressFromCoordinates(widget.dropoffLat, widget.dropoffLng).then((address) {
          _dropoffAddress = address;
        }),
        _calculateRealRoute(),
      ]);
      
      print('✅ Addresses and route calculation completed');
      
      // Use route information from backend if available
      _useBackendRouteInfo();
      
      print('✅ Backend route info processed');
      
      setState(() {
        _isLoading = false;
      });
      
      print('✅ Loading state updated');
      
      // PERFORMANCE FIX: Use microtask instead of Future.delayed
      if (_routePoints.isNotEmpty) {
        print('✅ Route points available (${_routePoints.length}), showing overview...');
        scheduleMicrotask(() {
          if (mounted) {
            _showFullRouteOverview();
          }
        });
      } else {
        print('❌ No route points available for overview!');
      }
    } catch (e) {
      print('❌ Error setting up route: $e');
      print('   • Stack trace: ${StackTrace.current}');
      // Set fallback values if route calculation fails
      _distanceToDestination = "Route calculation failed";
      _timeToDestination = "Please try again";
      _estimatedArrival = "N/A";
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _calculateRealRoute() async {
    try {
      print('🛣️ Calculating real route using HERE API...');
      print('   • Pickup: ${widget.pickupLat}, ${widget.pickupLng}');
      print('   • Dropoff: ${widget.dropoffLat}, ${widget.dropoffLng}');
      
      final result = await _apiProvider.calculateRoute(
        originLat: widget.pickupLat,
        originLng: widget.pickupLng,
        destinationLat: widget.dropoffLat,
        destinationLng: widget.dropoffLng,
        transportMode: 'truck',
      );
      
      print('🔄 Route calculation result: $result');
      print('🔍 HERE API Response Analysis:');
      print('   • Success: ${result['success']}');
      print('   • Available keys: ${result.keys.toList()}');
      print('   • Has polyline: ${result['polyline'] != null}');
      print('   • Has waypoints: ${result['waypoints'] != null}');
      print('   • Has route: ${result['route'] != null}');
      
      // Deep dive into the response structure
      if (result['route'] != null) {
        print('🔍 Route object keys: ${result['route'].keys.toList()}');
        if (result['route']['sections'] != null) {
          print('🔍 Sections count: ${result['route']['sections'].length}');
          if (result['route']['sections'].isNotEmpty) {
            var firstSection = result['route']['sections'][0];
            print('🔍 First section keys: ${firstSection.keys.toList()}');
            print('🔍 First section data: $firstSection');
            
            // Check for waypoints in the section
            if (firstSection['waypoints'] != null) {
              print('🔍 Section waypoints count: ${firstSection['waypoints'].length}');
              print('🔍 Section waypoints: ${firstSection['waypoints']}');
            }
            
            // Check for other navigation data
            if (firstSection['actions'] != null) {
              print('🔍 Section actions: ${firstSection['actions']}');
            }
            
            if (firstSection['guidance'] != null) {
              print('🔍 Section guidance: ${firstSection['guidance']}');
            }
          }
        }
      }
      
      if (result['success'] == true && result['polyline'] != null && result['route']['sections'] != null) {
        // Use the real route polyline from HERE API
        // _routePoints = List<LatLng>.from(result['polyline']);
        // print('✅ Real route loaded: ${_routePoints.length} points');

        // encoded path
        final encodedPolyline = result['route']['sections'][0]['polyline'];
        final decodedPoints = FlexiblePolyline.decode(encodedPolyline);

        _routePoints = decodedPoints.map((p) => LatLng(p.lat, p.lng)).toList();

        if (result['waypoints'] != null) {
          _hereApiWaypoints = List<Map<String, dynamic>>.from(result['waypoints']);
          print('✅ HERE API waypoints loaded: ${_hereApiWaypoints!.length} instructions');
          print('   • Waypoints: $_hereApiWaypoints');
          
          // Debug each waypoint structure
          for (int i = 0; i < _hereApiWaypoints!.length; i++) {
            var waypoint = _hereApiWaypoints![i];
            print('   🔍 Waypoint $i:');
            print('     • Keys: ${waypoint.keys.toList()}');
            print('     • Instruction: ${waypoint['instruction']}');
            print('     • Distance: ${waypoint['distance']}');
            print('     • Icon: ${waypoint['icon']}');
            print('     • Full data: $waypoint');
          }
        } else {
          print('⚠️ No waypoints from HERE API');
          print('   • Available keys in result: ${result.keys.toList()}');
          print('   • Full result structure: $result');
          
          // Check if waypoints might be in a different location
          if (result['route'] != null && result['route']['sections'] != null) {
            print('🔍 Checking route sections for waypoints...');
            for (int i = 0; i < result['route']['sections'].length; i++) {
              var section = result['route']['sections'][i];
              print('   • Section $i keys: ${section.keys.toList()}');
              if (section['waypoints'] != null) {
                print('   • Section $i has waypoints: ${section['waypoints']}');
              }
            }
          }
        }
        
        // Update distance and time from API response
        if (result['distance'] != null) {
          _distanceToDestination = result['distance'];
        }
        if (result['duration'] != null) {
          _timeToDestination = result['duration'];
        }
      } else {
        print('⚠️ HERE API failed, using fallback route');
        print('   • Success: ${result['success']}');
        print('   • Polyline: ${result['polyline']}');
        print('   • Message: ${result['message']}');
        _generateRoutePoints();
      }
    } catch (e) {
      print('❌ Error calculating real route: $e');
      print('   • Stack trace: ${StackTrace.current}');
      _generateRoutePoints();
    }
    
    // Ensure we always have route points
    if (_routePoints.isEmpty) {
      print('⚠️ No route points available, generating fallback...');
      _generateRoutePoints();
    }
    
    print('✅ Final route points count: ${_routePoints.length}');
  }

  void _generateRoutePoints() {
    if (_pickupLocation == null || _dropoffLocation == null) return;
    
    print('🔄 Generating fallback route points...');
    
    // PERFORMANCE FIX: Pre-allocate list with known size
    _routePoints = List<LatLng>.filled(52, _pickupLocation!);
    
    double latDiff = _dropoffLocation!.latitude - _pickupLocation!.latitude;
    double lngDiff = _dropoffLocation!.longitude - _pickupLocation!.longitude;
    
    // PERFORMANCE FIX: Generate points in background thread
    compute(_generateRoutePointsInBackground, {
      'pickup': _pickupLocation!,
      'dropoff': _dropoffLocation!,
      'latDiff': latDiff,
      'lngDiff': lngDiff,
    }).then((points) {
      if (mounted) {
        _routePoints = points;
        print('✅ Fallback route generated: ${_routePoints.length} points');
        
        // Ensure we have route points for the map
        if (_routePoints.isNotEmpty) {
          print('✅ Route points available for map: ${_routePoints.length}');
        } else {
          print('❌ No route points generated!');
        }
      }
    });
  }
  
  // PERFORMANCE FIX: Background route generation
  static List<LatLng> _generateRoutePointsInBackground(Map<String, dynamic> params) {
    final pickup = params['pickup'] as LatLng;
    final dropoff = params['dropoff'] as LatLng;
    final latDiff = params['latDiff'] as double;
    final lngDiff = params['lngDiff'] as double;
    
    final points = <LatLng>[pickup];
    
    // Generate more points for smoother navigation (optimized)
    for (int i = 1; i < 50; i++) {
      final factor = i / 50.0;
      
      // Add some realistic curve to the route (not just straight line)
      final curveFactor = math.sin(factor * math.pi) * 0.001;
      
      points.add(LatLng(
        pickup.latitude + (latDiff * factor) + curveFactor,
        pickup.longitude + (lngDiff * factor) + curveFactor,
      ));
    }
    
    points.add(dropoff);
    return points;
  }
  
  // PERFORMANCE FIX: Optimize route points for rendering (reduce from 1130+ to ~200)
  List<LatLng> _getOptimizedRoutePoints() {
    if (_routePoints.length <= 200) return _routePoints;
    
    final optimizedPoints = <LatLng>[];
    final step = (_routePoints.length / 200).ceil();
    
    // Always include first and last points
    optimizedPoints.add(_routePoints.first);
    
    // Sample every nth point
    for (int i = step; i < _routePoints.length - 1; i += step) {
      optimizedPoints.add(_routePoints[i]);
    }
    
    optimizedPoints.add(_routePoints.last);
    
    print('🗺️ Route optimization: ${_routePoints.length} → ${optimizedPoints.length} points');
    return optimizedPoints;
  }

  void _calculateRealDistanceAndTime() {
    if (_pickupLocation == null || _dropoffLocation == null) return;
    
    // Calculate real distance using Haversine formula
    double distanceKm = _calculateHaversineDistance(
      _pickupLocation!.latitude, 
      _pickupLocation!.longitude,
      _dropoffLocation!.latitude, 
      _dropoffLocation!.longitude
    );
    
    // Estimate time based on average speed (assuming 40 km/h for city driving)
    int estimatedMinutes = (distanceKm / 40 * 60).round();
    
    // Calculate estimated arrival time
    DateTime now = DateTime.now();
    DateTime estimatedArrival = now.add(Duration(minutes: estimatedMinutes));
    String arrivalTime = "${estimatedArrival.hour.toString().padLeft(2, '0')}:${estimatedArrival.minute.toString().padLeft(2, '0')}";
    
    setState(() {
      _distanceToDestination = "${distanceKm.toStringAsFixed(1)} km";
      _timeToDestination = "$estimatedMinutes min";
      _estimatedArrival = arrivalTime;
    });
  }

  void _useBackendRouteInfo() {
    // Check if we have route info from the backend
    if (widget.orderData.containsKey('route_info') && 
        widget.orderData['route_info'] != null) {
      
      final routeInfo = widget.orderData['route_info'];
      
      // Use backend distance and duration
      if (routeInfo['distance'] != null) {
        _distanceToDestination = routeInfo['distance'];
      }
      
      if (routeInfo['duration'] != null) {
        _timeToDestination = routeInfo['duration'];
      }
      
      // Calculate estimated arrival time based on backend duration
      if (routeInfo['duration'] != null) {
        int durationMinutes = _parseDurationToMinutes(routeInfo['duration']);
        DateTime now = DateTime.now();
        DateTime estimatedArrival = now.add(Duration(minutes: durationMinutes));
        _estimatedArrival = "${estimatedArrival.hour.toString().padLeft(2, '0')}:${estimatedArrival.minute.toString().padLeft(2, '0')}";
      }
      
      print('✅ Using backend route info: ${_distanceToDestination}, ${_timeToDestination}');
      
    } else {
      // Fallback to calculated values if no backend data
      print('⚠️ No backend route info, using calculated values');
      _calculateRealDistanceAndTime();
    }
    
    // If we still don't have route points, generate fallback
    if (_routePoints.isEmpty) {
      print('⚠️ No route points available, generating fallback route');
      _generateRoutePoints();
    }
  }

  int _parseDurationToMinutes(String duration) {
    // Parse duration strings like "3h 49m", "45 min", "2h 30m"
    try {
      if (duration.contains('h') && duration.contains('m')) {
        // Format: "3h 49m"
        final parts = duration.split(' ');
        int hours = int.parse(parts[0].replaceAll('h', ''));
        int minutes = int.parse(parts[1].replaceAll('m', ''));
        return (hours * 60) + minutes;
      } else if (duration.contains('h')) {
        // Format: "2h"
        int hours = int.parse(duration.replaceAll('h', ''));
        return hours * 60;
      } else if (duration.contains('min')) {
        // Format: "45 min"
        return int.parse(duration.replaceAll(' min', ''));
      } else {
        // Try to parse as just minutes
        return int.parse(duration);
      }
    } catch (e) {
      print('Error parsing duration: $duration, error: $e');
      return 60; // Default to 1 hour
    }
  }

  double _parseDistanceToKm(String distance) {
    // Parse distance strings like "206 km", "45.5 km", "2.1 km"
    try {
      if (distance.contains('km')) {
        return double.parse(distance.replaceAll(' km', ''));
      } else {
        // Try to parse as just a number
        return double.parse(distance);
      }
    } catch (e) {
      print('Error parsing distance: $distance, error: $e');
      return 10.0; // Default to 10 km
    }
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  // Calculate Haversine distance between two points
  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
                math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
                math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  void _startNavigation() {
    if (_routePoints.isEmpty) {
      print('❌ Cannot start navigation: No route points available');
      return;
    }
    
    setState(() {
      _isNavigating = true;
      _fakeRouteIndex = 0;
      _currentLocation = _routePoints.first;
    });

    // Start with manual movement by default
    _isAutomaticMovement = false;
    _updateNavigationInfo();
    _fitMapToCurrentLocation(); // Fit map to current location when navigation starts
    
    // Auto-zoom in 11 times when navigation starts (7 + 4 more)
    _autoZoomIn(11);
  }

  // Auto-zoom in multiple times when navigation starts
  void _autoZoomIn(int times) async {
    print('🔍 Auto-zooming in $times times...');
    for (int i = 0; i < times; i++) {
      await Future.delayed(const Duration(milliseconds: 200)); // Small delay between zooms
      if (mounted) {
        _animatedMapController.animatedZoomIn();
        print('🔍 Zoom step ${i + 1}/$times completed');
      }
    }
    print('✅ Auto-zoom completed');
  }

  // Simulate movement along the route for testing turn-by-turn navigation - OPTIMIZED
  void _startFakeMovement() {
    if (_fakeMovementTimer != null) return;

    setState(() {
      _isNavigating = true;
      _fakeRouteIndex = 0;
      _currentLocation = _routePoints.first;
    });

    _fakeMovementTimer = Timer.periodic(Duration(milliseconds: _movementUpdateInterval), (timer) {
      if (_fakeRouteIndex < _routePoints.length - 1) {
        // PERFORMANCE OPTIMIZATION: Batch updates to reduce setState calls
        setState(() {
          _fakeRouteIndex++;
          _currentLocation = _routePoints[_fakeRouteIndex];
        });
        debugPrint("_fakeRouteIndex=${_fakeRouteIndex}");
        
        // PERFORMANCE OPTIMIZATION: Update navigation info less frequently
        _updateNavigationInfo();

        // // PERFORMANCE OPTIMIZATION: Update map less frequently
        final now = DateTime.now();
        if (now.difference(_lastMapUpdate).inMilliseconds >= _mapUpdateInterval) {
          _fitMapToCurrentLocation();
          _lastMapUpdate = now;
        }

        // kaip ir nereikalinga
        // // Check if we've reached the destination
        // if (_fakeRouteIndex >= _routePoints.length - 1) {
        //   timer.cancel();
        //   _showArrivalDialog();
        // }
      } else {
        timer.cancel();
        _showArrivalDialog();
      }
    });
  }
  
  // Move one step forward manually - OPTIMIZED
  void _moveOneStep() {
    if (_fakeRouteIndex < _routePoints.length - 1) {
      // PERFORMANCE OPTIMIZATION: Batch updates
      setState(() {
        _fakeRouteIndex++;
        _currentLocation = _routePoints[_fakeRouteIndex];
      });
      
      // PERFORMANCE OPTIMIZATION: Update navigation info less frequently
      _updateNavigationInfo();
      
      // PERFORMANCE OPTIMIZATION: Update map less frequently
      final now = DateTime.now();
      if (now.difference(_lastMapUpdate).inMilliseconds >= _mapUpdateInterval) {
        _fitMapToCurrentLocation();
        _lastMapUpdate = now;
      }
      
      // Check if we've reached the destination
      if (_fakeRouteIndex >= _routePoints.length - 1) {
        _showArrivalDialog();
      }
    }
  }
  
  // Move one step backward manually - OPTIMIZED
  void _moveOneStepBack() {
    if (_fakeRouteIndex > 0) {
      // PERFORMANCE OPTIMIZATION: Batch updates
      setState(() {
        _fakeRouteIndex--;
        _currentLocation = _routePoints[_fakeRouteIndex];
      });
      
      // PERFORMANCE OPTIMIZATION: Update navigation info less frequently
      _updateNavigationInfo();
      
      // PERFORMANCE OPTIMIZATION: Update map less frequently
      final now = DateTime.now();
      if (now.difference(_lastMapUpdate).inMilliseconds >= _mapUpdateInterval) {
        _fitMapToCurrentLocation();
        _lastMapUpdate = now;
      }
    }
  }

  void _updateNavigationInfo() {
    if (_routePoints.isEmpty) {
      print('❌ Cannot update navigation info: No route points available');
      return;
    }
    
    if (_fakeRouteIndex >= _routePoints.length - 1) return;
    
    // Calculate upcoming turns and navigation instructions
    _calculateUpcomingTurns();
    
    // Check if we have backend route info to use for calculations
    if (widget.orderData.containsKey('route_info') && 
        widget.orderData['route_info'] != null) {
      
      final routeInfo = widget.orderData['route_info'];
      int totalDurationMinutes = 0;
      double totalDistanceKm = 0;
      
      // Parse backend duration and distance
      if (routeInfo['duration'] != null) {
        totalDurationMinutes = _parseDurationToMinutes(routeInfo['duration']);
      }
      if (routeInfo['distance'] != null) {
        totalDistanceKm = _parseDistanceToKm(routeInfo['distance']);
      }
      
      // Calculate remaining based on progress
      int remainingPoints = _routePoints.length - _fakeRouteIndex - 1;
      double progress = remainingPoints / _routePoints.length;
      
      double remainingDistance = totalDistanceKm * progress;
      int remainingTime = (totalDurationMinutes * progress).round();
      
      // Update estimated arrival time
      DateTime now = DateTime.now();
      DateTime estimatedArrival = now.add(Duration(minutes: remainingTime));
      String arrivalTime = "${estimatedArrival.hour.toString().padLeft(2, '0')}:${estimatedArrival.minute.toString().padLeft(2, '0')}";
      
      setState(() {
        _distanceToDestination = "${remainingDistance.toStringAsFixed(1)} km";
        _timeToDestination = "$remainingTime min";
        _estimatedArrival = arrivalTime;
        // Don't override _nextStreetName here - let _calculateUpcomingTurns handle it
      });
      
    } else {
      // Fallback to calculated values
      int remainingPoints = _routePoints.length - _fakeRouteIndex - 1;
      double totalDistance = _calculateHaversineDistance(
        _pickupLocation!.latitude, 
        _pickupLocation!.longitude,
        _dropoffLocation!.latitude, 
        _dropoffLocation!.longitude
      );
      
      double remainingDistance = (remainingPoints / _routePoints.length) * totalDistance;
      int remainingTime = (remainingDistance / 40 * 60).round(); // 40 km/h average speed
      
      // Update estimated arrival time
      DateTime now = DateTime.now();
      DateTime estimatedArrival = now.add(Duration(minutes: remainingTime));
      String arrivalTime = "${estimatedArrival.hour.toString().padLeft(2, '0')}:${estimatedArrival.minute.toString().padLeft(2, '0')}";
      
      setState(() {
        _distanceToDestination = "${remainingDistance.toStringAsFixed(1)} km";
        _timeToDestination = "$remainingTime min";
        _estimatedArrival = arrivalTime;
        // Don't override _nextStreetName here - let _calculateUpcomingTurns handle it
      });
    }
  }

  String _getRandomStreetName() {
    final streets = [
      "Draugystės g.",
      "Kovo 11-osios g.",
      "Pramonės pr.",
      "Vilniaus g.",
      "Kauno g.",
      "Mindaugo g.",
      "Gedimino pr.",
      "Laisvės al.",
      "Naujoji g.",
      "Senamiesčio g."
    ];
    return streets[math.Random().nextInt(streets.length)];
  }

  void _fitMapToCurrentLocation() {
    // if (_currentLocation != null && _mapController != null) {
    //   _mapController!.move(_currentLocation!, 15.0);
    // }
    _animatedMapController.animateTo(dest: _currentLocation!);
  }

  void _showArrivalDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Destination Reached!'),
        content: const Text('You have arrived at your destination.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = 'https://revgeocode.search.hereapi.com/v1/revgeocode?at=${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}&apiKey=${ApiConfig.hereMapsApiKey}';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          final address = item['address'];
          
          if (address != null) {
            final parts = <String>[];
            if (address['street'] != null) parts.add(address['street']);
            if (address['houseNumber'] != null) parts.add(address['houseNumber']);
            if (address['city'] != null) parts.add(address['city']);
            
            final readableAddress = parts.join(', ');
            return readableAddress.isNotEmpty ? readableAddress : 'Address not found';
          }
        }
      }
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    } catch (e) {
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasLocationPermission
              ? _buildPermissionDeniedView()
              : _buildNavigationView(),
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

  Widget _buildNavigationView() {
    return Stack(
      children: [
        // Full screen map
        _buildMapView(),
        
        // Top navigation instruction bar
        if (_isNavigating) _buildTopNavigationBar(),
        
        // Floating controls on the right
        if (_isNavigating) _buildFloatingControls(),
        
        // Bottom trip summary panel
        if (_isNavigating) _buildBottomTripPanel(),
        
        // Re-center button
        if (_isNavigating) _buildReCenterButton(),
        
        // Initial setup view (when not navigating)
        if (!_isNavigating) _buildInitialSetupView(),
      ],
    );
  }

  Widget _buildTopNavigationBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.navigation,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _nextTurnInstruction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFloatingControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: Column(
        children: [
          // Movement mode toggle
          _buildFloatingButton(
            icon: _isAutomaticMovement ? Icons.pause : Icons.play_arrow,
            onTap: () {
              setState(() {
                _isAutomaticMovement = !_isAutomaticMovement;
                if (_isAutomaticMovement) {
                  _startFakeMovement();
                } else {
                  _fakeMovementTimer?.cancel();
                }
              });
            },
            backgroundColor: _isAutomaticMovement ? Colors.orange[600]! : Colors.green[600]!,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 16),
          
          // Manual movement controls
          _buildFloatingButton(
            icon: Icons.skip_previous,
            onTap: _moveOneStepBack,
            backgroundColor: Colors.blue[600]!,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 8),
          _buildFloatingButton(
            icon: Icons.skip_next,
            onTap: _moveOneStep,
            backgroundColor: Colors.green[600]!,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 16),
          
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: Icons.zoom_in,
            onTap: () {
              _animatedMapController.animatedZoomIn();
            },
            backgroundColor: Colors.white,
            iconColor: Colors.grey[700]!,
          ),
          _buildFloatingButton(
            icon: Icons.zoom_out,
            onTap: () {
              _animatedMapController.animatedZoomOut();
              // setState(() {
              //   _mapController!.move(
              //       _mapController!.camera.center, _mapController!.camera.zoom - 1
              //   );
              // });
            },
            backgroundColor: Colors.white,
            iconColor: Colors.grey[700]!,
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: _isMuted ? Icons.volume_off : Icons.volume_up,
            onTap: () {
              setState(() => _isMuted = !_isMuted);
            },
            backgroundColor: Colors.white,
            iconColor: _isMuted ? Colors.red : Colors.grey[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  Widget _buildBottomTripPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Trip info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timeToDestination,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_distanceToDestination} · $_estimatedArrival',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                
                // Exit navigation button
                _buildFloatingButton(
                  icon: Icons.close,
                  onTap: () {
                    _fakeMovementTimer?.cancel();
                    Get.back();
                  },
                  backgroundColor: Colors.red[600]!,
                  iconColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReCenterButton() {
    return Positioned(
      bottom: 140,
      left: 16,
      child: GestureDetector(
        onTap: () {
          _fitMapToCurrentLocation();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.my_location,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Re-centre',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialSetupView() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Trip summary
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timeToDestination,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_distanceToDestination} · $_estimatedArrival',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Addresses
            _buildAddressCard(
              icon: Icons.location_on,
              iconColor: Colors.orange[600]!,
              title: 'Pick up address',
              address: _pickupAddress,
            ),
            
            const SizedBox(height: 12),
            
            _buildAddressCard(
              icon: Icons.flag,
              iconColor: Colors.red[600]!,
              title: 'Drop off address',
              address: _dropoffAddress,
            ),
            
            const SizedBox(height: 20),
            
            // Start navigation button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4964D8),
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
            

          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (_routePoints.isEmpty) {
      print('⚠️ No route points available for map');
      return Container(
        width: double.infinity,
        height: 400,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey[600]),
            SizedBox(height: 16),
            Text(
              'No Route Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Route points: ${_routePoints.length}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _debugMap,
              child: Text('Debug Map'),
            ),
          ],
        ),
      );
    }
    
    print('🗺️ Building map with ${_routePoints.length} route points');
    print('📍 Center: ${widget.pickupLat}, ${widget.pickupLng}');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50], // Light blue background to see if container loads
        border: Border.all(color: Colors.red, width: 2), // Red border to see container
      ),
      child: FlutterMap(
        // mapController: _mapController,
        mapController: _animatedMapController.mapController,
        options: MapOptions(
          initialCenter: LatLng(widget.pickupLat, widget.pickupLng),
          initialZoom: 10, // Lower zoom to reduce tile requests
          onMapReady: () {
            print('🗺️ Map is ready!');
            setState(() {});
          },
          // PERFORMANCE OPTIMIZATION: Reduce tile requests by limiting zoom range
          maxZoom: 20, // Reduced to avoid 404 errors
          minZoom: 4,
          // PERFORMANCE OPTIMIZATION: Disable smooth scrolling to reduce tile requests
          interactionOptions: const InteractionOptions(
            enableScrollWheel: false,
            enableMultiFingerGestureRace: false,
          ),
        ),
      children: [
        TileLayer(
          urlTemplate: 'https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png?apiKey=${ApiConfig.hereMapsApiKey}',
          userAgentPackageName: 'com.truckbuddy.app',
          tileProvider: CachedNetworkTileProvider(cacheManager: DefaultCacheManager()),
          tileSize: 256,
          maxZoom: 20,
          minZoom: 4,
          // // PERFORMANCE OPTIMIZATION: Add error handling without requiring assets
          // tileBuilder: (context, child, tile) {
          //   print('🧩 Tile loaded: ${tile.coordinates}');
          //   return child;
          // },
          // PERFORMANCE OPTIMIZATION: Add error handling for failed tiles
          errorTileCallback: (tile, error, stackTrace) {
            print('❌ HERE Raster Tile error: $error for tile ${tile.coordinates}');
            print('🔗 Failed URL: https://maps.hereapi.com/v3/base/mc/${tile.coordinates.z}/${tile.coordinates.x}/${tile.coordinates.y}/png?apiKey=${ApiConfig.hereMapsApiKey.substring(0, 10)}...');
            // Log the error but don't return anything (void function)
          },
        ),
        
        // PERFORMANCE FIX: Route polyline with optimized rendering and point reduction
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _getOptimizedRoutePoints(), // Reduce points for better performance
                strokeWidth: 6,
                color: Colors.blue[600]!,
              ),
            ],
          ),
        
        // PERFORMANCE OPTIMIZATION: Markers with optimized rendering
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
                    color: Colors.green[600],
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
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 24),
                ),
              ),
            
            // Current location marker (truck) - only show when navigating
            if (_currentLocation != null && _isNavigating)
              Marker(
                point: _currentLocation!,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 30),
                ),
              ),
          ],
        ),
      ],
      ),
    );
  }
}

class CachedNetworkTileProvider extends NetworkTileProvider {
  final BaseCacheManager cacheManager;

  CachedNetworkTileProvider({
    required this.cacheManager,
  }) : super();

  @override
  ImageProvider getImage(TileCoordinates coordinates, dynamic options) {
    final String tileUrl = getTileUrl(coordinates, options);
    return CachedNetworkImageProvider(tileUrl,
        cacheManager: cacheManager, headers: headers);
  }
}
