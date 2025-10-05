import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppConstData/typographyy.dart';
import '../AppConstData/routes.dart';
import '../Api_Provider/api_provider.dart';

class NewDeliveryModal extends StatefulWidget {
  final String selectedAddress;
  final double? selectedLat;
  final double? selectedLng;
  final String? currentAddress;
  final double? currentLat;
  final double? currentLng;

  const NewDeliveryModal({
    Key? key,
    required this.selectedAddress,
    this.selectedLat,
    this.selectedLng,
    this.currentAddress,
    this.currentLat,
    this.currentLng,
  }) : super(key: key);

  @override
  State<NewDeliveryModal> createState() => _NewDeliveryModalState();
}

class _NewDeliveryModalState extends State<NewDeliveryModal> {
  String _distance = "Calculating...";
  String _duration = "Calculating...";
  bool _isCalculating = true;
  final ApiProvider _apiProvider = ApiProvider();

  @override
  void initState() {
    super.initState();
    _calculateRouteInfo();
  }

  void _calculateRouteInfo() async {
    print('🔍 DELIVERY MODAL DEBUG:');
    print('   • Current Lat: ${widget.currentLat}');
    print('   • Current Lng: ${widget.currentLng}');
    print('   • Selected Lat: ${widget.selectedLat}');
    print('   • Selected Lng: ${widget.selectedLng}');
    print('   • Current Address: ${widget.currentAddress}');
    print('   • Selected Address: ${widget.selectedAddress}');
    
    // Use Vilnius Cathedral as pickup location for route calculation
    double pickupLat = 54.6864; // Vilnius Cathedral latitude
    double pickupLng = 25.2872; // Vilnius Cathedral longitude
    double dropoffLat = widget.selectedLat ?? 54.6864;
    double dropoffLng = widget.selectedLng ?? 25.2872;
    
    print('🛣️ Using Vilnius Cathedral as pickup for route calculation...');
    print('   • Pickup: $pickupLat, $pickupLng (Vilnius Cathedral)');
    print('   • Dropoff: $dropoffLat, $dropoffLng');

    try {
      print('🛣️ Calculating route from Vilnius Cathedral to selected address...');
      final result = await _apiProvider.calculateRoute(
        originLat: pickupLat,
        originLng: pickupLng,
        destinationLat: dropoffLat,
        destinationLng: dropoffLng,
        transportMode: 'truck',
      );

      print('🛣️ Route calculation result: $result');

      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _distance = result['distance'] ?? "Unknown";
            _duration = result['duration'] ?? "Unknown";
            print('✅ Route calculated successfully: $_distance, $_duration');
          } else {
            _distance = "Route not found";
            _duration = "N/A";
            print('❌ Route calculation failed: ${result['message']}');
          }
          _isCalculating = false;
        });
      }
    } catch (e) {
      print('❌ Error calculating route: $e');
      if (mounted) {
        setState(() {
          _distance = "Error calculating";
          _duration = "N/A";
          _isCalculating = false;
        });
      }
    }
  }

  void _confirmAndGo() async {
    // Use Vilnius Cathedral as temporary current location for testing
    // This ensures we always have reasonable coordinates for route calculation
    double pickupLat = 54.6864; // Vilnius Cathedral latitude
    double pickupLng = 25.2872; // Vilnius Cathedral longitude
    double dropoffLat = widget.selectedLat ?? 54.6864;
    double dropoffLng = widget.selectedLng ?? 25.2872;
    
    print('🚀 Navigating to live navigation with:');
    print('   • Using Vilnius Cathedral as pickup location');
    print('   • Pickup: $pickupLat, $pickupLng (Vilnius Cathedral)');
    print('   • Dropoff: $dropoffLat, $dropoffLng');
    
    // Navigate to live navigation screen first
    print('🚀 Attempting to navigate to live navigation screen...');
    try {
      await Get.toNamed(Routes.liveNavigation, arguments: {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'pickupAddress': "Vilnius Cathedral", // Use Vilnius Cathedral as pickup
        'dropoffAddress': widget.selectedAddress,
        'orderData': {
          'route_info': {
            'distance': _distance,
            'duration': _duration,
          }
        }
      });
      print('✅ Navigation to live navigation screen completed');
    } catch (e) {
      print('❌ Error navigating to live navigation screen: $e');
    }
    
    // Close the modal after navigation
    print('🚪 Closing delivery modal...');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  "New Delivery",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontFamily: fontFamilyBold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Delivery details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Distance and time
                  _buildInfoSection(
                    icon: Icons.access_time,
                    iconColor: const Color(0xFF4964D8),
                    title: 'Distance',
                    content: _isCalculating 
                        ? 'Calculating...' 
                        : '$_duration ($_distance) total',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pick up address
                  _buildInfoSection(
                    icon: Icons.location_on,
                    iconColor: const Color(0xFF4964D8),
                    title: 'Pick up address',
                    content: "Vilnius Cathedral",
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Drop off address
                  _buildInfoSection(
                    icon: Icons.flag,
                    iconColor: const Color(0xFF4964D8),
                    title: 'Drop off address',
                    content: widget.selectedAddress,
                  ),
                  
                  const Spacer(),
                  
                  // Confirm & Go button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCalculating ? null : _confirmAndGo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4964D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isCalculating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Confirm & Go',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamilyBold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
