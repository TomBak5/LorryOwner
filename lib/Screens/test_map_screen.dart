import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppConstData/app_colors.dart';
import '../widgets/widgets.dart';

class TestMapScreen extends StatelessWidget {
  const TestMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Load Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Load Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Dummy load details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Load #12345',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pickup: Mumbai, Maharashtra'),
                  const Text('Drop: Delhi, Delhi'),
                  const Text('Weight: 10 tons'),
                  const Text('Rate: ₹50,000'),
                  const SizedBox(height: 16),
                  
                  // Show Route Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/loadRouteMap');
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Show Route on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Testing Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Tap "Show Route on Map" button'),
                  Text('2. Should open Google Maps screen'),
                  Text('3. Should show pickup and drop markers'),
                  Text('4. Should show route line between points'),
                  Text('5. Should be able to navigate back'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 