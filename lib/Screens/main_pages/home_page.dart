// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:movers_lorry_owner/Controllers/homepage_controller.dart';

import '../../AppConstData/managepage.dart';
import '../../AppConstData/routes.dart';
import '../../AppConstData/api_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController homePageController = Get.put(HomePageController());
  MapController? _mapController;
  Position? _currentPosition;
  bool _isLocationLoading = true;
  Timer? _debounceTimer;
  String _currentAddress = 'Getting location...';
  
  // Set your real location coordinates here
  // You can update these with your actual coordinates
  static const double _realLatitude = 54.6872;  // Change to your actual latitude
  static const double _realLongitude = 25.2797; // Change to your actual longitude
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    homePageController.getDataFromLocalData().then((value) {
      if (homePageController.userData != null && (homePageController.userData?.id?.isNotEmpty ?? false)) {
        homePageController.getHomePageData(uid: homePageController.userData!.id!);
        // Get assigned trucks for drivers
        if (homePageController.userData?.userRole != 'dispatcher') {
          homePageController.getAssignedTrucks();
        }
      } else {
        homePageController.setIsLoading(false);
      }
      homePageController.setIcon(homePageController.verification12(homePageController.userData?.isVerify ?? ''));
      ManagePageCalling().setLogin(false);
    });
    ManagePageCalling().setLogin(false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('Starting location request...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location services enabled: $serviceEnabled');
      if (!serviceEnabled) {
        setState(() {
          _isLocationLoading = false;
          _currentAddress = 'Location services disabled';
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Initial permission: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocationLoading = false;
            _currentAddress = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocationLoading = false;
          _currentAddress = 'Location permission permanently denied';
        });
        return;
      }

      // Get current position
      debugPrint('Requesting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      debugPrint('Position received: Lat: ${position.latitude}, Lng: ${position.longitude}');

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });

      // Get address from coordinates
      debugPrint('Getting address from coordinates...');
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Move camera to current location if map controller is available
      if (_mapController != null && _currentPosition != null) {
        _mapController!.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Fallback to a default location if GPS fails
      debugPrint('Using fallback location...');
      Position fallbackPosition = Position(
        latitude: _realLatitude, // Your real location
        longitude: _realLongitude,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      
      setState(() {
        _currentPosition = fallbackPosition;
        _isLocationLoading = false;
      });
      
      await _getAddressFromCoordinates(fallbackPosition.latitude, fallbackPosition.longitude);
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      debugPrint('Geocoding coordinates: Lat: $latitude, Lng: $longitude');
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      debugPrint('Found ${placemarks.length} placemarks');
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        debugPrint('Place details: Street: ${place.street}, Locality: ${place.locality}, AdminArea: ${place.administrativeArea}, Country: ${place.country}');
        
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }
        
        debugPrint('Final address: $address');
        setState(() {
          _currentAddress = address.isNotEmpty ? address : 'Address not available';
        });
      } else {
        debugPrint('No placemarks found');
        setState(() {
          _currentAddress = 'Address not available';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _currentAddress = 'Address not available';
      });
    }
  }

  Future<void> _searchNearbyFuelStations() async {
    // Navigate to the dedicated fuel stations screen
    Get.toNamed(Routes.fuelStations);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: GetBuilder<HomePageController>(
            builder: (homePageController) {
              if (homePageController.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (homePageController.userData == null || (homePageController.userData?.id?.isEmpty ?? true)) {
                // Redirect to login screen if no user is found
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.offAllNamed(Routes.loginScreen);
                });
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(
                      const Duration(seconds: 1),
                      () {
                        homePageController.updateUserProfile(context);
                      },
                    );
                  },
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight((Get.height * 0.12) - 60), // Reduce header by 60px
                      child: AppBar(
                        toolbarHeight: (Get.height * 0.12) - 60, // Reduce header by 60px
                        backgroundColor: Colors.white,
                        elevation: 0,
                        titleSpacing: 0,
                        title: Column(
                          children: [
                            ListTile(
                              dense: true,
                              leading: const SizedBox(width: 0),
                              trailing: InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.notification);
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  radius: 20,
                                  child: SvgPicture.asset(
                                    "assets/icons/notification.svg",
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Stack(
                      children: [
                        // Full screen map
                        _buildMapView(),
                        
                        
                        // Bottom driver/truck info panel (draggable bottom sheet)
                        _buildBottomInfoPanel(homePageController),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
        // TruckBuddy logo positioned 15px up from previous position
        Positioned(
          left: -40,
          top: 86, // Subtracted 15px from 101
          child: Image.asset(
            "assets/logo/truckbuddy_logo.png",
            height: 24,
            width: 295,
            fit: BoxFit.contain,
          ),
        ),
        // Ring bell icon positioned 15px up from previous position
        Positioned(
          right: 40,
          top: 86, // Subtracted 15px from 101
          child: Image.asset(
            "assets/icons/bellring.png",
            height: 24,
            width: 24,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Positioned(
      left: 0, // Start from left edge
      right: 0, // Extend to right edge (full width)
      top: (Get.height * 0.12) - 60, // Lift map by 60px (header height - 60px)
      child: Container(
        width: double.infinity, // Full screen width
        height: 609, // Height from Figma (height: 609)
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: _isLocationLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : FlutterMap(
              mapController: _mapController ?? MapController(),
              options: MapOptions(
                initialCenter: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(54.6872, 25.2797), // Fallback to Vilnius
                initialZoom: _currentPosition != null ? 15.0 : 10.0,
                onMapReady: () {
                  print('🗺️ Home page map is ready!');
                  // Move camera to current location if available
                  if (_currentPosition != null && _mapController != null) {
                    _mapController!.move(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      15.0,
                    );
                  }
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
                  tileSize: 256,
                  maxZoom: 20,
                  minZoom: 4,
                  errorTileCallback: (tile, error, stackTrace) {
                    print('❌ HERE Raster Tile error: $error for tile ${tile.coordinates}');
                    print('🔗 Failed URL: https://maps.hereapi.com/v3/base/mc/${tile.coordinates.z}/${tile.coordinates.x}/${tile.coordinates.y}/png?apiKey=${ApiConfig.hereMapsApiKey.substring(0, 10)}...');
                  },
                ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      ),
    );
  }


  Widget _buildBottomInfoPanel(HomePageController homePageController) {
    return Positioned(
      bottom: 20, // Move card up by 20px to create gap from bottom
      left: 30, // Add 30px gap from left
      right: 30, // Add 30px gap from right
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // All corners rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            // Driver info
            _buildDriverInfoCard(homePageController),
            
            const SizedBox(height: 12),
            
            // Truck details
            if (homePageController.getCurrentAssignedTruck() != null)
              _buildTruckDetailsCard(homePageController),
            
            const SizedBox(height: 12),
            
            // Separator line
            Container(
              height: 1,
              color: const Color(0xFFF0F0F0),
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons (moved from floating controls)
            _buildActionButtonsRow(),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard(HomePageController homePageController) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  homePageController.userData?.name ?? 'Driver',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentAddress,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckDetailsCard(HomePageController homePageController) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.local_shipping, color: Colors.green[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned Truck',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  homePageController.getCurrentAssignedTruck()?['truck_title'] ?? 'Truck Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${homePageController.getCurrentAssignedTruck()?['truck_brand'] ?? 'Brand'} ${homePageController.getCurrentAssignedTruck()?['truck_model'] ?? 'Model'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Truck No: ${homePageController.getCurrentAssignedTruck()?['truck_no'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          imagePath: 'assets/icons/fuel icon.png',
          label: 'Fuel',
          onTap: _searchNearbyFuelStations,
        ),
        _buildActionButton(
          imagePath: 'assets/icons/truck stops.png',
          label: 'Truck Stops',
          onTap: () {
            // TODO: Implement truck stops functionality
          },
        ),
        _buildActionButton(
          imagePath: 'assets/icons/weighing.png',
          label: 'Weigh',
          onTap: () {
            // TODO: Implement weigh functionality
          },
        ),
        _buildMoreButton(
          label: 'More',
          onTap: () {
            // TODO: Implement more functionality
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            child: imagePath.endsWith('.svg') 
              ? Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  color: Colors.blue[600],
                )
              : Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            child: const Icon(
              Icons.more_horiz,
              color: Colors.blue,
              size: 50,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}
