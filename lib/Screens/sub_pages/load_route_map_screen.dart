import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LoadRouteMapScreen extends StatelessWidget {
  final double pickLat;
  final double pickLng;
  final double dropLat;
  final double dropLng;

  const LoadRouteMapScreen({
    Key? key,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.dropLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng pickup = LatLng(pickLat, pickLng);
    final LatLng drop = LatLng(dropLat, dropLng);
    return Scaffold(
      appBar: AppBar(title: Text('Load Route Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: pickup, zoom: 8),
        markers: {
          Marker(markerId: MarkerId('pickup'), position: pickup, infoWindow: InfoWindow(title: 'Pickup')),
          Marker(markerId: MarkerId('drop'), position: drop, infoWindow: InfoWindow(title: 'Drop')),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: [pickup, drop],
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }
} 