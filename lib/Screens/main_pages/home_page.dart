// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:movers_lorry_owner/constants/app_dimensions.dart';
import 'package:movers_lorry_owner/Controllers/homepage_controller.dart';

import '../../AppConstData/managepage.dart';
import '../../AppConstData/routes.dart';
import '../../AppConstData/api_config.dart';
import '../../Api_Provider/api_provider.dart';

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
  
  // Address search variables
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _addressSuggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  LatLng? _selectedAddressLocation; // Store selected address coordinates
  
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
    _searchController.dispose();
    super.dispose();
  }
  
  // Address search methods
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _addressSuggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set up new timer for debounced search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchAddresses(query);
    });
  }
  
  Future<void> _searchAddresses(String query) async {
    if (query.length < 3) return;
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      final apiProvider = ApiProvider();
      final suggestions = await apiProvider.getAddressSuggestions(query);
      
      setState(() {
        _addressSuggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching addresses: $e');
      setState(() {
        _addressSuggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
    }
  }
  
  void _selectAddress(Map<String, dynamic> address) {
    setState(() {
      _searchController.text = address['address'];
      _showSuggestions = false;
      // Store selected address coordinates for marker
      _selectedAddressLocation = LatLng(address['latitude'], address['longitude']);
    });
    
    // Move map to selected address
    if (_mapController != null) {
      _mapController!.move(
        LatLng(address['latitude'], address['longitude']),
        15.0,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('Starting location request...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location services enabled: $serviceEnabled');
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLocationLoading = false;
            _currentAddress = 'Location services disabled';
          });
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Initial permission: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLocationLoading = false;
              _currentAddress = 'Location permission denied';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLocationLoading = false;
            _currentAddress = 'Location permission permanently denied';
          });
        }
        return;
      }

      // Get current position
      debugPrint('Requesting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      debugPrint('Position received: Lat: ${position.latitude}, Lng: ${position.longitude}');

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocationLoading = false;
        });
      }

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
      
      if (mounted) {
        setState(() {
          _currentPosition = fallbackPosition;
          _isLocationLoading = false;
        });
      }
      
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
        if (mounted) {
          setState(() {
            _currentAddress = address.isNotEmpty ? address : 'Address not available';
          });
        }
      } else {
        debugPrint('No placemarks found');
        if (mounted) {
          setState(() {
            _currentAddress = 'Address not available';
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Address not available';
        });
      }
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
              // Wait for user data to be loaded before making redirect decision
              if (homePageController.isLoading) {
                return const Scaffold(
                  body: SizedBox.shrink(),
                );
              }
              
              if (homePageController.userData == null || (homePageController.userData?.id?.isEmpty ?? true)) {
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
                      preferredSize: Size.fromHeight(80), // Reduced from 118px to 80px
                      child: AppBar(
                        toolbarHeight: 80, // Reduced from 118px to 80px
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
        // Ring bell icon positioned to match Frame 4 from CSS
        Positioned(
          right: 14, // Frame 4 is at the right side of Frame 3 (347px wide in 375px container)
          top: 61, // Exact Y position as specified
          child: Container(
            width: 40, // Frame 4 width
            height: 40, // Frame 4 height
            child: Center(
              child: Image.asset(
                "assets/icons/bellring.png",
                height: 24, // Frame width
                width: 24, // Frame height
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Group 17 logo at specified position
        Positioned(
          left: 14,
          top: 71, // Exact Y position as specified
          child: Image.asset(
            "assets/logo/Group 17 (1).png",
            width: 173,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        // Search field
        Positioned(
          top: 134, // Y position as specified
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 375, // Set width as specified
                  height: 82, // Set height as specified
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/bg/Frame 6.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Search icon
                      Positioned(
                        left: 30, // X position as specified
                        top: 26, // Moved down by 5px from 21px
                        child: Image.asset(
                          "assets/icons/Frame (3).png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Text input field
                      Positioned(
                        left: 61, // X position as specified
                        top: 9, // Lifted up by 3px (12 - 3 = 9)
                        right: 60, // Leave space for right icon
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter delivery address",
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.5, // line-height: 21px / font-size: 14px = 1.5
                              color: Color(0xFF929292),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      // Right side icon
                      Positioned(
                        right: 30, // Aligned to the right with 30px margin
                        top: 28, // Same vertical position as text for alignment
                        child: Image.asset(
                          "assets/icons/Frame (4).png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                // Address suggestions dropdown
                if (_showSuggestions && _addressSuggestions.isNotEmpty)
                  Container(
                    width: 375,
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _addressSuggestions.map((suggestion) {
                        return ListTile(
                          leading: Icon(Icons.location_on, color: Colors.blue),
                          title: Text(
                            suggestion['address'],
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectAddress(suggestion),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Positioned(
      left: 0, // Start from left edge
      right: 0, // Extend to right edge (full width)
      top: 40, // Reset to original position
      child: Container(
        width: double.infinity, // Full screen width
        height: 669.0.h, // Increased height by 60px (609.0.h + 60 = 669.0.h)
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
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
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
                // Current location marker
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
                // Selected address marker (pin/drop icon)
                if (_selectedAddressLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedAddressLocation!,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.place,
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
      top: 461.0.h, // Moved down by another 30px (431.0.h + 30 = 461.0.h)
      left: AppDimensions.cardMarginHorizontal,
      right: AppDimensions.cardMarginHorizontal,
      child: Container(
        padding: EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
            
            SizedBox(height: AppDimensions.spacingMedium),
            
            // Truck details
            if (homePageController.getCurrentAssignedTruck() != null)
              _buildTruckDetailsCard(homePageController),
            
            SizedBox(height: AppDimensions.spacingMedium),
            
            // Separator line
            Container(
              height: AppDimensions.separatorHeight,
              color: Color(AppDimensions.separatorColor),
            ),
            
            SizedBox(height: AppDimensions.spacingMedium),
            
            // Action buttons (moved from floating controls)
            _buildActionButtonsRow(),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard(HomePageController homePageController) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.driverInfoPadding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.driverIconPadding),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.iconContainerRadius),
            ),
            child: Icon(Icons.person, color: Colors.blue[600], size: AppDimensions.driverIconSize),
          ),
          SizedBox(width: 16.0.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  homePageController.userData?.name ?? 'Driver',
                  style: TextStyle(
                    fontSize: AppDimensions.textLarge,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.0.h),
                Text(
                  _currentAddress,
                  style: TextStyle(
                    fontSize: AppDimensions.textSmall,
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
      padding: EdgeInsets.all(AppDimensions.driverInfoPadding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.driverIconPadding),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.iconContainerRadius),
            ),
            child: Icon(Icons.local_shipping, color: Colors.green[600], size: AppDimensions.driverIconSize),
          ),
          SizedBox(width: 16.0.w),
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
                    fontSize: AppDimensions.textSmall,
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
    // Show only Create Order button for dispatchers
    if (homePageController.userData?.userRole == 'dispatcher') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            imagePath: 'assets/icons/fuel icon.png', // Using existing icon for now
            label: 'Create Order',
            onTap: () {
              Get.toNamed(Routes.assignOrder);
            },
          ),
        ],
      );
    }
    
    // Show driver buttons for regular drivers
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
            width: AppDimensions.buttonSize,
            height: AppDimensions.buttonSize,
            child: imagePath.endsWith('.svg') 
              ? Image.asset(
                  imagePath,
                  width: AppDimensions.iconSize,
                  height: AppDimensions.iconSize,
                  color: Colors.blue[600],
                )
              : Image.asset(
                  imagePath,
                  width: AppDimensions.iconSize,
                  height: AppDimensions.iconSize,
                ),
          ),
          SizedBox(height: AppDimensions.spacingSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.textSmall,
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
            width: AppDimensions.buttonSize,
            height: AppDimensions.buttonSize,
            child: Icon(
              Icons.more_horiz,
              color: Colors.blue,
              size: AppDimensions.iconSize,
            ),
          ),
          SizedBox(height: AppDimensions.spacingSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.textSmall,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}
