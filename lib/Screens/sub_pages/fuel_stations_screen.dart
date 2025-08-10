import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:movers_lorry_owner/Controllers/fuel_stations_controller.dart';
import 'package:movers_lorry_owner/AppConstData/app_colors.dart';
import 'package:movers_lorry_owner/AppConstData/typographyy.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';

class FuelStationsScreen extends StatelessWidget {
  const FuelStationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FuelStationsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: priMaryColor,
        elevation: 0,
        title: Text(
          'Fuel Stations',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "urbani_extrabold",
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshFuelStations(),
          ),
        ],
      ),
      body: GetBuilder<FuelStationsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching for nearby fuel stations...'),
                ],
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.getCurrentLocation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: priMaryColor,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.fuelStations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_gas_station_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No fuel stations found nearby',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try increasing the search radius or check your location',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Map Section
              Container(
                height: 350,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: MapController(),
                    options: MapOptions(
                      initialCenter: controller.currentPosition != null
                          ? LatLng(
                              controller.currentPosition!.latitude,
                              controller.currentPosition!.longitude,
                            )
                          : const LatLng(54.6872, 25.2797), // Fallback to Vilnius
                      initialZoom: 13.0,
                      onMapReady: () {
                        // Adjust map bounds to show all markers
                        if (controller.fuelStations.isNotEmpty) {
                          final bounds = _calculateMapBounds(controller);
                          // You can use bounds to fit all markers if needed
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.moverslorryowner.app',
                      ),
                      // Current location marker
                      if (controller.currentPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                controller.currentPosition!.latitude,
                                controller.currentPosition!.longitude,
                              ),
                              width: 80,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blue, width: 2),
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      // Fuel stations markers
                      MarkerLayer(
                        markers: controller.fuelStations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final station = entry.value;
                          final isClosest = index == 0; // First station is closest
                          
                          return Marker(
                            point: LatLng(
                              station.latitude ?? 0,
                              station.longitude ?? 0,
                            ),
                            width: isClosest ? 80 : 60,
                            height: isClosest ? 80 : 60,
                            child: GestureDetector(
                              onTap: () {
                                _showStationDetails(context, station, index + 1);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isClosest ? Colors.green : Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isClosest ? Colors.green.shade700 : Colors.orange.shade700,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_gas_station,
                                      color: Colors.white,
                                      size: isClosest ? 24 : 20,
                                    ),
                                    if (isClosest)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade700,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '1st',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Closest Station Highlight
              if (controller.fuelStations.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_gas_station,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Closest Station',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              controller.fuelStations.first.name ?? 'Fuel Station',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: fontFamilyBold,
                              ),
                            ),
                            Text(
                              '${controller.fuelStations.first.distance ?? 0}m away',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.directions, color: Colors.green),
                        onPressed: () => _openDirections(controller.fuelStations.first),
                      ),
                    ],
                  ),
                ),
              
              // Stations List Section
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.fuelStations.length,
                  itemBuilder: (context, index) {
                    final station = controller.fuelStations[index];
                    final isClosest = index == 0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isClosest ? 4 : 2,
                      color: isClosest ? Colors.green.shade50 : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isClosest ? Colors.green[100] : Colors.orange[100],
                          child: Icon(
                            Icons.local_gas_station,
                            color: isClosest ? Colors.green[600] : Colors.orange[600],
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                station.name ?? 'Fuel Station',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamilyBold,
                                  color: isClosest ? Colors.green[800] : null,
                                ),
                              ),
                            ),
                            if (isClosest)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'CLOSEST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.address ?? 'Address not available',
                              style: TextStyle(
                                color: textGreyColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${station.rating?.toStringAsFixed(1) ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: isClosest ? Colors.green[600] : Colors.red[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${station.distance ?? 0}m',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isClosest ? FontWeight.bold : FontWeight.normal,
                                    color: isClosest ? Colors.green[700] : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.directions,
                            color: isClosest ? Colors.green[600] : Colors.blue[600],
                          ),
                          onPressed: () {
                            _openDirections(station);
                          },
                        ),
                        onTap: () {
                          _showStationDetails(context, station, index + 1);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Calculate map bounds to show all markers
  LatLngBounds _calculateMapBounds(FuelStationsController controller) {
    if (controller.currentPosition == null || controller.fuelStations.isEmpty) {
      return LatLngBounds(
        const LatLng(54.6872, 25.2797),
        const LatLng(54.6872, 25.2797),
      );
    }

    double minLat = controller.currentPosition!.latitude;
    double maxLat = controller.currentPosition!.latitude;
    double minLng = controller.currentPosition!.longitude;
    double maxLng = controller.currentPosition!.longitude;

    for (final station in controller.fuelStations) {
      if (station.latitude != null && station.longitude != null) {
        minLat = math.min(minLat, station.latitude!);
        maxLat = math.max(maxLat, station.latitude!);
        minLng = math.min(minLng, station.longitude!);
        maxLng = math.max(maxLng, station.longitude!);
      }
    }

    // Add some padding
    const padding = 0.01;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  void _showStationDetails(BuildContext context, station, int rank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: rank == 1 ? Colors.green[100] : Colors.orange[100],
                  child: Icon(
                    Icons.local_gas_station,
                    color: rank == 1 ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              station.name ?? 'Fuel Station',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamilyBold,
                              ),
                            ),
                          ),
                          if (rank == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'CLOSEST',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        station.address ?? 'Address not available',
                        style: TextStyle(
                          color: textGreyColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  'Rating: ${station.rating?.toStringAsFixed(1) ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.location_on,
                  color: rank == 1 ? Colors.green[600] : Colors.red[400],
                ),
                const SizedBox(width: 8),
                Text(
                  '${station.distance ?? 0}m away',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: rank == 1 ? FontWeight.bold : FontWeight.normal,
                    color: rank == 1 ? Colors.green[700] : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (station.openingHours != null && station.openingHours!.isNotEmpty) ...[
              const Text(
                'Opening Hours:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...station.openingHours!.map((hours) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(hours),
              )),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openDirections(station);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: priMaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDirections(station) {
    if (station.latitude != null && station.longitude != null) {
      // Open in default maps app
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${station.latitude},${station.longitude}';
      // You can use url_launcher package to open this URL
      // For now, just show a message
      Get.snackbar(
        'Directions',
        'Opening directions to ${station.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    }
  }
}
