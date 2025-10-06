import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:truckbuddy/Api_Provider/api_provider.dart';
import 'package:truckbuddy/models/fuel_station_model.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class FuelStationsController extends GetxController {
  List<FuelStation> fuelStations = [];
  Position? currentPosition;
  bool isLoading = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage = 'Location permission denied';
          isLoading = false;
          update();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage = 'Location permissions are permanently denied';
        isLoading = false;
        update();
        return;
      }

      // Get current position
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get fuel stations once we have location
      await getFuelStations();
    } catch (e) {
      errorMessage = 'Error getting location: $e';
      isLoading = false;
      update();
    }
  }

  Future<void> getFuelStations() async {
    if (currentPosition == null) {
      errorMessage = 'Location not available';
      update();
      return;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      debugPrint('🔍 Searching for fuel stations near: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
      
      final response = await ApiProvider().getFuelStations(
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
        radius: 10000, // Increased radius to 10km for better coverage
      );

      debugPrint('📡 HERE API Response: $response');

      if (response != null && response['Result'] == 'true') {
        final fuelStationsResponse = FuelStationsResponse.fromJson(response);
        fuelStations = fuelStationsResponse.fuelStations ?? [];
        
        // Sort fuel stations by distance (closest first)
        fuelStations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        
        debugPrint('✅ Found ${fuelStations.length} fuel stations');
        
        if (fuelStations.isNotEmpty) {
          // Log first few stations for debugging
          for (int i = 0; i < fuelStations.length && i < 3; i++) {
            final station = fuelStations[i];
            debugPrint('📍 Station ${i + 1}: ${station.name} - ${station.distance}m away');
          }
        }
        
        errorMessage = null;
        
        // If no fuel stations found, show fallback data
        if (fuelStations.isEmpty) {
          debugPrint('⚠️ No fuel stations found, showing fallback data');
          fuelStations = _getFallbackFuelStations();
        }
      } else {
        errorMessage = response?['ResponseMsg'] ?? 'Failed to load fuel stations';
        debugPrint('❌ API Error: $errorMessage');
        fuelStations = _getFallbackFuelStations();
      }
    } catch (e) {
      errorMessage = 'Error loading fuel stations: $e';
      debugPrint('💥 Exception: $e');
      fuelStations = _getFallbackFuelStations();
    } finally {
      isLoading = false;
      update();
    }
  }

  // Fallback fuel stations if HERE API fails
  List<FuelStation> _getFallbackFuelStations() {
    if (currentPosition == null) return [];
    
    debugPrint('🔄 Using fallback fuel stations');
    
    return [
      FuelStation(
        id: '1',
        name: 'Shell Fuel Station',
        address: 'Sample Address 1, Near Current Location',
        latitude: currentPosition!.latitude + 0.001,
        longitude: currentPosition!.longitude + 0.001,
        distance: 500,
        category: 'fuel',
        icon: 'https://example.com/shell.png',
        rating: 4.5,
        openingHours: ['Open 24/7']
      ),
      FuelStation(
        id: '2',
        name: 'BP Fuel Station',
        address: 'Sample Address 2, Near Current Location',
        latitude: currentPosition!.latitude - 0.001,
        longitude: currentPosition!.longitude - 0.001,
        distance: 800,
        category: 'fuel',
        icon: 'https://example.com/bp.png',
        rating: 4.2,
        openingHours: ['6:00 AM - 10:00 PM']
      ),
      FuelStation(
        id: '3',
        name: 'Exxon Fuel Station',
        address: 'Sample Address 3, Near Current Location',
        latitude: currentPosition!.latitude + 0.002,
        longitude: currentPosition!.longitude - 0.002,
        distance: 1200,
        category: 'fuel',
        icon: 'https://example.com/exxon.png',
        rating: 4.0,
        openingHours: ['5:00 AM - 11:00 PM']
      ),
      FuelStation(
        id: '4',
        name: 'Circle K Fuel Station',
        address: 'Sample Address 4, Near Current Location',
        latitude: currentPosition!.latitude - 0.002,
        longitude: currentPosition!.longitude + 0.002,
        distance: 1500,
        category: 'fuel',
        icon: 'https://example.com/circlek.png',
        rating: 3.8,
        openingHours: ['Open 24/7']
      ),
      FuelStation(
        id: '5',
        name: 'Mobil Fuel Station',
        address: 'Sample Address 5, Near Current Location',
        latitude: currentPosition!.latitude + 0.003,
        longitude: currentPosition!.longitude + 0.001,
        distance: 2000,
        category: 'fuel',
        icon: 'https://example.com/mobil.png',
        rating: 4.1,
        openingHours: ['7:00 AM - 9:00 PM']
      )
    ];
  }

  Future<void> refreshFuelStations() async {
    await getFuelStations();
  }

  // Get the closest fuel station
  FuelStation? getClosestFuelStation() {
    if (fuelStations.isEmpty) return null;
    return fuelStations.first; // Already sorted by distance
  }

  // Get fuel stations within a specific radius
  List<FuelStation> getFuelStationsWithinRadius(double radiusInMeters) {
    return fuelStations.where((station) => 
      (station.distance ?? 0) <= radiusInMeters
    ).toList();
  }

  // Calculate distance between two points (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
