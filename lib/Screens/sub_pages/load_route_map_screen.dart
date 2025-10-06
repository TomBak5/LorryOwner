import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Load Route Map')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Route Map',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Pickup: ${pickLat.toStringAsFixed(6)}, ${pickLng.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Drop: ${dropLat.toStringAsFixed(6)}, ${dropLng.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Map functionality will be implemented later',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
} 
