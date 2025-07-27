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
    final data = await ApiProvider().fetchVehicleBrands();
    setState(() {
      brands = data;
      isLoadingBrands = false;
    });
  }

  void fetchTrailerTypes() async {
    setState(() => isLoadingTrailerTypes = true);
    try {
      print('Fetching comprehensive truck types...');
      final data = await ApiProvider().fetchComprehensiveTruckTypes();
      print('Truck types received: ${data.length} items');
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
                      hint: Text('Select brand'),
                      items: brands.map((b) => DropdownMenuItem(
                        value: b['id'].toString(),
                        child: Text(b['brand_name'] ?? ''),
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
                      hint: Text('Select trailer type'),
                      items: trailerTypes.map((t) => DropdownMenuItem(
                        value: t['id'].toString(),
                        child: Text(t['name'] ?? ''),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedTrailerTypeId = val;
                          selectedTrailerTypeObj = trailerTypes.firstWhere(
                            (t) => t['id'].toString() == val,
                            orElse: () => {},
                          );
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
                    if (selectedTrailerTypeId != null) {
                      singUpController.selectedTrailerType = selectedTrailerTypeId;
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
                    Get.offAll(() => HomePage());
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