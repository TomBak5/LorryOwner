import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/api_config.dart';

class NavigationTestScreen extends StatefulWidget {
  const NavigationTestScreen({Key? key}) : super(key: key);

  @override
  State<NavigationTestScreen> createState() => _NavigationTestScreenState();
}

class _NavigationTestScreenState extends State<NavigationTestScreen> {
  final ApiProvider _apiProvider = ApiProvider();
  bool _isLoading = false;
  Map<String, dynamic>? _testResults;
  String _statusMessage = 'Ready to test';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('HERE Navigation Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    if (_testResults != null) ...[
                      const SizedBox(height: 16),
                      _buildTestResults(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runFullTest,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Full Navigation Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testRouteCalculation,
              icon: const Icon(Icons.route),
              label: const Text('Test Route Calculation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGeocoding,
              icon: const Icon(Icons.location_on),
              label: const Text('Test Geocoding'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFuelStations,
              icon: const Icon(Icons.local_gas_station),
              label: const Text('Test Fuel Stations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCustomRoute,
              icon: const Icon(Icons.edit_location),
              label: const Text('Test Custom Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    if (_testResults == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Results:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildResultRow('API Key', _testResults!['api_key_working'] ?? false),
        _buildResultRow('Routing', _testResults!['routing_working'] ?? false),
        _buildResultRow('Geocoding', _testResults!['geocoding_working'] ?? false),
        _buildResultRow('Search', _testResults!['search_working'] ?? false),
      ],
    );
  }

  Widget _buildResultRow(String label, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('$label: ${isSuccess ? '✅ Working' : '❌ Failed'}'),
        ],
      ),
    );
  }

  Future<void> _runFullTest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Running full navigation test...';
    });

    try {
      final results = await _apiProvider.testHereApiAuthorization();
      setState(() {
        _testResults = results;
        _statusMessage = results['success'] == true 
            ? '✅ All tests passed!' 
            : '❌ Some tests failed';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testRouteCalculation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing route calculation...';
    });

    try {
      // Test route from Times Square to Empire State Building
      final result = await _apiProvider.calculateRoute(
        originLat: 40.7580, // Times Square
        originLng: -73.9855,
        destinationLat: 40.7484, // Empire State Building
        destinationLng: -73.9857,
        transportMode: 'truck',
      );

      setState(() {
        _statusMessage = result['success'] == true
            ? '✅ Route calculated: ${result['distance']?.toStringAsFixed(1)} km, ${result['duration']?.toStringAsFixed(0)} min'
            : '❌ Route calculation failed: ${result['message']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Route test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGeocoding() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing geocoding...';
    });

    try {
      final result = await _apiProvider.getCoordinatesFromAddress('Times Square, New York');
      
      setState(() {
        _statusMessage = result['success'] == true
            ? '✅ Geocoding successful: ${result['latitude']}, ${result['longitude']}'
            : '❌ Geocoding failed: ${result['message']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Geocoding test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFuelStations() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing fuel stations search...';
    });

    try {
      final result = await _apiProvider.getFuelStations(
        lat: 40.7580, // Times Square
        lng: -73.9855,
        radius: 5000,
      );

      setState(() {
        _statusMessage = result['Result'] == 'true'
            ? '✅ Found ${result['fuelStations']?.length ?? 0} fuel stations'
            : '❌ Fuel stations search failed: ${result['ResponseMsg']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Fuel stations test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testCustomRoute() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing custom route...';
    });

    try {
      // Test a longer route (Brooklyn to Queens)
      final result = await _apiProvider.calculateRoute(
        originLat: 40.6782, // Brooklyn
        originLng: -73.9442,
        destinationLat: 40.7282, // Queens
        destinationLng: -73.7949,
        transportMode: 'truck',
      );

      setState(() {
        _statusMessage = result['success'] == true
            ? '✅ Custom route calculated: ${result['distance']?.toStringAsFixed(1)} km, ${result['duration']?.toStringAsFixed(0)} min'
            : '❌ Custom route failed: ${result['message']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Custom route test error: $e';
        _isLoading = false;
      });
    }
  }
}
