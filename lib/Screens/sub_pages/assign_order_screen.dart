import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Api_Provider/api_provider.dart';
import '../../Controllers/order_controller.dart';

class AssignOrderScreen extends StatefulWidget {
  const AssignOrderScreen({super.key});

  @override
  State<AssignOrderScreen> createState() => _AssignOrderScreenState();
}

class _AssignOrderScreenState extends State<AssignOrderScreen> {
  String? _selectedDriver;
  double _pickupLat = 0.0;
  double _pickupLng = 0.0;
  String _pickupAddress = '';
  double _deliveryLat = 0.0;
  double _deliveryLng = 0.0;
  String _deliveryAddress = '';
  
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoadingDrivers = true;
  String? _currentDispatcherId;
  final OrderController _orderController = Get.put(OrderController());

  // Add disposal tracking
  bool _disposed = false;
  
  // Add WebView controller
  WebViewController? webViewController;
  String gkey = "";

  @override
  void initState() {
    super.initState();
    print('=== AssignOrderScreen initState ===');
    getGkey();
    _getCurrentLocation();
    _loadAssignedDrivers();
  }

  getGkey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gkey = prefs.getString("gkey") ?? "AIzaSyAVOjpp1c4YXhmfO06ch3CurcxJBUgbyAw";
    });
  }

  @override
  void dispose() {
    _disposed = true;
    // Dispose WebView controller properly
    if (webViewController != null) {
      webViewController!.clearCache();
      webViewController!.clearLocalStorage();
    }
    super.dispose();
  }

  // Add safe setState method
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _getCurrentDispatcherId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString("userData");
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        _currentDispatcherId = userData["id"].toString();
        print('=== Current dispatcher ID: $_currentDispatcherId ===');
      }
    } catch (e) {
      print('Error getting current dispatcher ID: $e');
    }
  }

  Future<void> _loadAssignedDrivers() async {
      _safeSetState(() {
      _isLoadingDrivers = true;
    });

    try {
      await _getCurrentDispatcherId();
      
      if (_currentDispatcherId != null) {
        print('=== Loading drivers for dispatcher: $_currentDispatcherId ===');
        final apiProvider = ApiProvider();
        final assignedDrivers = await apiProvider.getDispatcherAssignedDrivers(_currentDispatcherId!);
        
        _safeSetState(() {
          _drivers = assignedDrivers;
          _isLoadingDrivers = false;
        });
        
        print('=== Loaded ${_drivers.length} assigned drivers ===');
        for (var driver in _drivers) {
          print('=== Driver: ${driver['name']} (${driver['email']}) ===');
        }
      } else {
        _safeSetState(() {
          _isLoadingDrivers = false;
        });
        Get.snackbar(
          'Error',
          'Could not determine dispatcher ID',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error loading assigned drivers: $e');
      _safeSetState(() {
        _isLoadingDrivers = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load assigned drivers',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      _safeSetState(() {
        _pickupLat = position.latitude;
        _pickupLng = position.longitude;
      });
      
      _getAddressFromLatLng(_pickupLat, _pickupLng, true);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng, bool isPickup) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        _safeSetState(() {
          if (isPickup) {
            _pickupAddress = address;
          } else {
            _deliveryAddress = address;
          }
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  void _selectLocation(bool isPickup) {
    print('=== Opening MapPickerScreen for ${isPickup ? "pickup" : "delivery"} ===');
    Get.to(() => MapPickerScreen(
      initialLat: isPickup ? _pickupLat : _deliveryLat,
      initialLng: isPickup ? _pickupLng : _deliveryLng,
      onLocationSelected: (lat, lng, address) {
      _safeSetState(() {
          if (isPickup) {
            _pickupLat = lat;
            _pickupLng = lng;
            _pickupAddress = address;
          } else {
            _deliveryLat = lat;
            _deliveryLng = lng;
            _deliveryAddress = address;
          }
        });
      },
    ));
  }

  Future<void> _createAndAssignOrder() async {
    if (_currentDispatcherId == null || _selectedDriver == null) {
      Get.snackbar(
        'Error',
        'Please select a driver and ensure you are logged in',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      print('=== Creating order with driver: $_selectedDriver ===');
      print('=== Pickup: $_pickupAddress (${_pickupLat}, ${_pickupLng}) ===');
      print('=== Delivery: $_deliveryAddress (${_deliveryLat}, ${_deliveryLng}) ===');

      final success = await _orderController.createDispatcherOrder(
        dispatcherId: _currentDispatcherId!,
        driverId: _selectedDriver!,
        vehicleId: "1", // Default vehicle ID - you might want to add vehicle selection
        pickupPoint: _pickupAddress,
        dropPoint: _deliveryAddress,
        materialName: "General Cargo", // Default - you might want to add material selection
        weight: "1000", // Default weight in kg
        amount: "100", // Default amount
        amountType: "per_km", // Default amount type
        totalAmount: "500", // Default total amount
        description: "Order created from mobile app",
        pickupName: "Pickup Contact", // Default - you might want to add contact details
        pickupMobile: "1234567890", // Default
        dropName: "Delivery Contact", // Default
        dropMobile: "1234567890", // Default
        pickLat: _pickupLat,
        pickLng: _pickupLng,
        dropLat: _deliveryLat,
        dropLng: _deliveryLng,
        pickStateId: 1, // Default state ID
        dropStateId: 1, // Default state ID
      );

      if (success) {
        // Navigate back to previous screen
        Get.back();
      }
    } catch (e) {
      print('=== Error creating order: $e ===');
      Get.snackbar(
        'Error',
        'Failed to create order. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: priMaryColor,
        title: Text(
          'Assign Order',
          style: TextStyle(
            color: Colors.white,
            fontFamily: fontFamilyBold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Selection
            Text(
              'Select Driver',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamilyBold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoadingDrivers
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text('Loading assigned drivers...'),
                        ],
                      ),
                    )
                  : _drivers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                              Text(
                                'No drivers assigned',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: _loadAssignedDrivers,
                                child: Text('Refresh'),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDriver,
                            hint: Text('Select a driver'),
                            isExpanded: true,
                            items: _drivers.map((driver) {
                              return DropdownMenuItem<String>(
                                value: driver['id'].toString(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      driver['name'] ?? driver['email'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      driver['mobile'] ?? driver['email'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                          _safeSetState(() {
                                _selectedDriver = newValue;
                          });
                        },
                      ),
                        ),
            ),
            
            const SizedBox(height: 20),
            
            // Pickup Location
            Text(
              'Pickup Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamilyBold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectLocation(true),
                  child: Container(
                padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                    Icon(Icons.location_on, color: priMaryColor),
                    const SizedBox(width: 8),
                        Expanded(
                      child: Text(
                        _pickupAddress.isNotEmpty ? _pickupAddress : 'Select pickup location',
                        style: TextStyle(
                          color: _pickupAddress.isNotEmpty ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Delivery Location
            Text(
              'Delivery Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamilyBold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectLocation(false),
                    child: Container(
                padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: priMaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _deliveryAddress.isNotEmpty ? _deliveryAddress : 'Select delivery location',
                        style: TextStyle(
                          color: _deliveryAddress.isNotEmpty ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Assign Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDriver != null && _pickupAddress.isNotEmpty && _deliveryAddress.isNotEmpty && !_orderController.isLoading
                    ? () => _createAndAssignOrder()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: priMaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _orderController.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Creating Order...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamilyBold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Assign Order',
                        style: TextStyle(
                          color: Colors.white,
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
}

class MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double, double, String) onLocationSelected;

  const MapPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationSelected,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  WebViewController? webViewController;
  double _selectedLat = 0.0;
  double _selectedLng = 0.0;
  String _selectedAddress = '';
  bool _isSearching = false;
  List<String> _searchResults = [];
  bool _showSearchResults = false;
  bool _mapLoadError = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Add disposal tracking
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    print('=== MapPickerScreen initState ===');
    _selectedLat = widget.initialLat;
    _selectedLng = widget.initialLng;
    _getAddressFromLatLng(_selectedLat, _selectedLng);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    if (webViewController != null) {
      webViewController!.clearCache();
      webViewController!.clearLocalStorage();
    }
  }

  // Add safe setState method
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
      _safeSetState(() {
          _selectedAddress = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

      _safeSetState(() {
      _isSearching = true;
      _showSearchResults = false;
      });

      try {
      List<Location> locations = await locationFromAddress(query);
      List<String> addresses = [];

      for (Location location in locations.take(5)) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          addresses.add('${place.street}, ${place.locality}, ${place.administrativeArea}');
        }
      }

            _safeSetState(() {
        _searchResults = addresses;
        _showSearchResults = true;
        _isSearching = false;
      });

      // Update map with first result
      if (locations.isNotEmpty) {
        _updateMapLocation(locations.first.latitude, locations.first.longitude);
        }
      } catch (e) {
      print('Error searching location: $e');
        _safeSetState(() {
        _isSearching = false;
      });
    }
  }

  void _updateMapLocation(double lat, double lng) {
    if (webViewController != null) {
      webViewController!.runJavaScript('''
        // Clear existing markers
        if (window.map && window.markers) {
          window.markers.forEach(marker => map.removeObject(marker));
          window.markers = [];
        }
        
        // Move map to new location
        if (window.map) {
          window.map.setCenter({lat: $lat, lng: $lng});
          window.map.setZoom(15);
          
          // Add new marker
          var marker = new H.map.Marker({lat: $lat, lng: $lng});
          window.map.addObject(marker);
          if (!window.markers) window.markers = [];
          window.markers.push(marker);
        }
      ''');
    }
  }

  void _selectSearchResult(String address) {
            _safeSetState(() {
      _showSearchResults = false;
    });
    _searchController.text = address;
    
    // Get coordinates for the selected address
    locationFromAddress(address).then((locations) {
      if (locations.isNotEmpty) {
        _updateMapLocation(locations.first.latitude, locations.first.longitude);
        _safeSetState(() {
          _selectedLat = locations.first.latitude;
          _selectedLng = locations.first.longitude;
        });
        _getAddressFromLatLng(_selectedLat, _selectedLng);
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      _safeSetState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
      });
      
      _getAddressFromLatLng(_selectedLat, _selectedLng);
      
      // Update map
      if (webViewController != null) {
        webViewController!.runJavaScript('''
          // Clear existing markers
          if (window.map && window.markers) {
            window.markers.forEach(marker => map.removeObject(marker));
            window.markers = [];
          }
          
          // Move map to current location
          if (window.map) {
            window.map.setCenter({lat: ${position.latitude}, lng: ${position.longitude}});
            window.map.setZoom(15);
            
            // Add new marker
            var marker = new H.map.Marker({lat: ${position.latitude}, lng: ${position.longitude}});
            window.map.addObject(marker);
            if (!window.markers) window.markers = [];
            window.markers.push(marker);
          }
        ''');
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: priMaryColor,
        title: Text(
          'Select Location',
          style: TextStyle(
            color: Colors.white,
            fontFamily: fontFamilyBold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
                            onPressed: () {
              widget.onLocationSelected(_selectedLat, _selectedLng, _selectedAddress);
              Get.back();
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontFamilyBold,
                fontSize: 16,
              ),
                        ),
                      ),
                    ],
                  ),
      body: Column(
        children: [
          // Search bar
                    Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
                    children: [
                      Expanded(
                  child: TextField(
                    controller: _searchController,
                          decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: Icon(Icons.search, color: priMaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _useCurrentLocation,
                  icon: Icon(Icons.my_location, color: priMaryColor),
                      ),
                    ],
                  ),
          ),
          
          // Search results
          if (_showSearchResults)
            Container(
              constraints: BoxConstraints(
                maxHeight: 120,
                minHeight: 60,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Icon(Icons.location_on, color: priMaryColor, size: 20),
                    title: Text(
                      _searchResults[index],
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () => _selectSearchResult(_searchResults[index]),
                  );
                },
              ),
            ),
          
          // Map
                      Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _mapLoadError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                  Text(
                              'Map Loading Error',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                        _safeSetState(() {
                                  _mapLoadError = false;
                        });
                      },
                              child: Text('Retry'),
                      ),
                    ],
                  ),
                      )
                    : WebViewWidget(
                        controller: (webViewController = WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..addJavaScriptChannel(
                            'flutter',
                            onMessageReceived: (JavaScriptMessage message) {
                              if (_disposed) return; // Prevent processing if disposed
                              print('=== JavaScript message received: ${message.message} ===');
                              try {
                                final data = jsonDecode(message.message);
                                if (data['type'] == 'locationSelected') {
                                  print('=== Location selected via map: ${data['lat']}, ${data['lng']} ===');
                                  _safeSetState(() {
                                    _selectedLat = data['lat'].toDouble();
                                    _selectedLng = data['lng'].toDouble();
                                  });
                                  _getAddressFromLatLng(_selectedLat, _selectedLng);
                                }
                              } catch (e) {
                                print('Error parsing JavaScript message: $e');
                              }
                            },
                          )
                          ..setNavigationDelegate(
                            NavigationDelegate(
                              onPageFinished: (String url) {
                                if (_disposed) return;
                                print('=== WebView page finished loading ===');
                              },
                              onWebResourceError: (WebResourceError error) {
                                if (_disposed) return;
                                print('=== WebView error: ${error.description} ===');
                                _safeSetState(() {
                                  _mapLoadError = true;
                                });
                              },
                            ),
                          )
                                                    ..loadHtmlString('''
                            <!DOCTYPE html>
                            <html>
                            <head>
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <style>
                                    body { margin: 0; padding: 0; }
                                    #map { width: 100%; height: 100vh; }
                                    .loading { 
                                        position: absolute; 
                                        top: 50%; 
                                        left: 50%; 
                                        transform: translate(-50%, -50%);
                                        color: #666;
                                    }
                                </style>
                                <script>
                                    function loadScript(src) {
                                        return new Promise((resolve, reject) => {
                                            const script = document.createElement('script');
                                            script.src = src;
                                            script.onload = resolve;
                                            script.onerror = reject;
                                            document.head.appendChild(script);
                                        });
                                    }
                                    
                                    async function initMap() {
                                        try {
                                            await loadScript('https://js.api.here.com/v3/3.1/mapsjs-core.js');
                                            await loadScript('https://js.api.here.com/v3/3.1/mapsjs-service.js');
                                            await loadScript('https://js.api.here.com/v3/3.1/mapsjs-ui.js');
                                            await loadScript('https://js.api.here.com/v3/3.1/mapsjs-mapevents.js');
                                            
                                                                                         // Initialize the platform
                                             const platform = new H.service.Platform({
                                                 apikey: 'q9Qb1k7st6xCwipGKkBErA'
                                             });
                                            
                                            const defaultLayers = platform.createDefaultLayers();
                                            const map = new H.Map(
                                                document.getElementById('map'),
                                                defaultLayers.vector.normal.map,
                                                {
                                                    center: {lat: ${widget.initialLat}, lng: ${widget.initialLng}},
                                                    zoom: 15
                                                }
                                            );
                                            
                                            window.map = map;
                                            window.markers = [];
                                            
                                            // Add map events
                                            const mapEvents = new H.mapevents.MapEvents(map);
                                            const behavior = new H.mapevents.Behavior(mapEvents);
                                            
                                            // Add click event
                                            map.addEventListener('tap', function(evt) {
                                                const coord = map.screenToGeo(evt.currentPointer.viewportX, evt.currentPointer.viewportY);
                                                
                                                // Clear existing markers
                                                window.markers.forEach(marker => map.removeObject(marker));
                                                window.markers = [];
                                                
                                                // Add new marker
                                                const marker = new H.map.Marker(coord);
                                                map.addObject(marker);
                                                window.markers.push(marker);
                                                
                                                // Send to Flutter
                                                flutter.postMessage(JSON.stringify({
                                                    type: 'locationSelected',
                                                    lat: coord.lat,
                                                    lng: coord.lng
                                                }));
                                            });
                                            
                                            // Add initial marker
                                            const initialMarker = new H.map.Marker({lat: ${widget.initialLat}, lng: ${widget.initialLng}});
                                            map.addObject(initialMarker);
                                            window.markers.push(initialMarker);
                                            
                                        } catch (error) {
                                            console.error('Error loading map:', error);
                                            document.getElementById('map').innerHTML = '<div class="loading">Error loading map</div>';
                                        }
                                    }
                                    
                                    // Initialize map when page loads
                                    window.addEventListener('load', initMap);
                                </script>
                            </head>
                            <body>
                                <div id="map">
                                    <div class="loading">Loading map...</div>
                                </div>
                            </body>
                            </html>
                          ''')
                        ),
                      ),
                      ),
                ),
              ),
            ],
      ),
    );
  }
} 