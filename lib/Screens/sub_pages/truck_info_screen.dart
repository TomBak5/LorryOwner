import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Api_Provider/api_provider.dart';
import '../main_pages/home_page.dart';
import 'account_info_screen.dart';
import '../../Controllers/singiup_controller.dart';

class TruckInfoScreen extends StatefulWidget {
  const TruckInfoScreen({Key? key}) : super(key: key);

  @override
  State<TruckInfoScreen> createState() => _TruckInfoScreenState();
}

class _TruckInfoScreenState extends State<TruckInfoScreen> {
  String? selectedBrand;
  String? selectedTrailerTypeId;
  Map<String, dynamic>? selectedTrailerTypeObj;
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> trailerTypes = [];
  bool isLoadingBrands = true;
  bool isLoadingTrailerTypes = true;

  @override
  void initState() {
    super.initState();
    fetchBrands();
    fetchTrailerTypes();
  }

  void fetchBrands() async {
    setState(() => isLoadingBrands = true);
    try {
      print('Fetching vehicle brands...');
      final data = await ApiProvider().fetchVehicleBrands();
      print('Brands received: ${data.length} items');
      
      // Debug: Print first few items to see the structure
      if (data.isNotEmpty) {
        print('First brand: ${data.first}');
        print('Available keys: ${data.first.keys.toList()}');
      }
      
      setState(() {
        brands = data;
        isLoadingBrands = false;
      });
    } catch (e) {
      print('Error fetching brands: $e');
      setState(() {
        brands = [];
        isLoadingBrands = false;
      });
    }
  }

  void fetchTrailerTypes() async {
    setState(() => isLoadingTrailerTypes = true);
    try {
      print('Fetching comprehensive truck types...');
      
      // First test API connection
      final apiTest = await ApiProvider().testApiConnection();
      print('API connection test: $apiTest');
      
      // Check if table exists
      final tableCheck = await ApiProvider().checkTrailerTypesTable();
      print('Table check: $tableCheck');
      
      // Fetch trailer types
      final data = await ApiProvider().fetchComprehensiveTruckTypes();
      print('Truck types received: ${data.length} items');
      
      // Debug: Print first few items to see the structure
      if (data.isNotEmpty) {
        print('First truck type: ${data.first}');
        print('Available keys: ${data.first.keys.toList()}');
      }
      
      setState(() {
        trailerTypes = data;
        isLoadingTrailerTypes = false;
      });
    } catch (e) {
      print('Error fetching truck types: $e');
      setState(() {
        trailerTypes = [];
        isLoadingTrailerTypes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Truck information', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)),
                  const Spacer(),
                  Text('1/3', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1 / 3,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 3,
              ),
              const SizedBox(height: 32),
              Text('Your Truck information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              const SizedBox(height: 32),
              Text('Truck brand', style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 8),
              isLoadingBrands
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedBrand,
                      hint: Text('Select brand (${brands.length} available)'),
                      items: brands.map((b) => DropdownMenuItem(
                        value: b['id'].toString(),
                        child: Text(b['brand_name'] ?? 'Unknown'),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedBrand = val),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
              const SizedBox(height: 20),
              Text('Trailer type', style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 8),
              isLoadingTrailerTypes
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedTrailerTypeId,
                      hint: Text('Select trailer type (${trailerTypes.length} available)'),
                      items: trailerTypes.map((t) => DropdownMenuItem(
                        value: t['id'].toString(),
                        child: Text(t['name'] ?? 'Unknown'),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedTrailerTypeId = val;
                          selectedTrailerTypeObj = trailerTypes.firstWhere(
                            (t) => t['id'].toString() == val,
                            orElse: () => {},
                          );
                          
                          // Debug: Print selected trailer type details
                          print('Selected trailer type ID: $val');
                          print('Selected trailer type object: $selectedTrailerTypeObj');
                          if (selectedTrailerTypeObj != null) {
                            print('Available keys: ${selectedTrailerTypeObj!.keys.toList()}');
                          }
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
              const SizedBox(height: 28),
              Text('Trailer information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              if (selectedTrailerTypeObj != null && selectedTrailerTypeObj!.isNotEmpty) ...[
                _infoRow('Length:', '${selectedTrailerTypeObj?['length_min'] ?? '—'} - ${selectedTrailerTypeObj?['length_max'] ?? '—'} m'),
                _infoRow('Width:', '${selectedTrailerTypeObj?['width'] ?? '—'} m'),
                _infoRow('Height:', selectedTrailerTypeObj?['height_min'] != null && selectedTrailerTypeObj?['height_max'] != null 
                  ? '${selectedTrailerTypeObj?['height_min']} - ${selectedTrailerTypeObj?['height_max']} m'
                  : selectedTrailerTypeObj?['height_min'] != null 
                    ? '${selectedTrailerTypeObj?['height_min']} m'
                    : '—'),
                _infoRow('Weight Capacity:', '${selectedTrailerTypeObj?['weight_capacity_lbs'] ?? '—'} lbs (${selectedTrailerTypeObj?['weight_capacity_kg'] ?? '—'} kg)'),
                _infoRow('Category:', selectedTrailerTypeObj?['category'] ?? '—'),
                _infoRow('Common Uses:', selectedTrailerTypeObj?['common_uses'] ?? '—'),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Select a trailer type to see details',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final singUpController = Get.find<SingUpController>();
                    final userRole = singUpController.selectedRole;
                    
                    // Save truck information to the controller
                    if (selectedBrand != null) {
                      singUpController.selectedBrand = selectedBrand;
                    }
                    if (selectedTrailerTypeObj != null) {
                      // Send the truck type NAME, not the ID
                      singUpController.selectedTrailerType = selectedTrailerTypeObj!['name'];
                      print('Saving truck type NAME: ${selectedTrailerTypeObj!['name']}');
                    }
                    
                    Get.to(() => AccountInfoScreen(userRole: userRole));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    final singUpController = Get.find<SingUpController>();
                    final userRole = singUpController.selectedRole;
                    
                    // Set default values when skipping (for drivers)
                    if (userRole == 'driver') {
                      // Set default truck brand and trailer type when skipping
                      singUpController.selectedBrand = '1'; // Default brand ID
                      singUpController.selectedTrailerType = 'Flatbed Trailers'; // Default trailer type NAME
                      print('Skipping truck selection - setting defaults: brand=1, trailer=Flatbed Trailers');
                    }
                    
                    Get.to(() => AccountInfoScreen(userRole: userRole));
                  },
                  child: Text('Skip now', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.black87, fontSize: 13))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black54, fontSize: 13))),
        ],
      ),
    );
  }
} 