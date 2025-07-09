import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Api_Provider/api_provider.dart';

class TruckInfoScreen extends StatefulWidget {
  const TruckInfoScreen({Key? key}) : super(key: key);

  @override
  State<TruckInfoScreen> createState() => _TruckInfoScreenState();
}

class _TruckInfoScreenState extends State<TruckInfoScreen> {
  String? selectedBrand;
  String? selectedTrailerType;
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
    final data = await ApiProvider().fetchTrailerTypes();
    setState(() {
      trailerTypes = data;
      isLoadingTrailerTypes = false;
    });
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
                      value: selectedTrailerType,
                      hint: Text('Select trailer type'),
                      items: trailerTypes.map((t) => DropdownMenuItem(
                        value: t['id'].toString(),
                        child: Text(t['trailer_type'] ?? ''),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedTrailerType = val),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
              const SizedBox(height: 28),
              Text('Trailer information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              // TODO: Display dimensions based on selected brand/type
              _infoRow('Length:', '28 ft – 53 ft (8.5 m – 16.2 m)'),
              _infoRow('Width:', '8.5 ft (2.6 m)'),
              _infoRow('Height:', '8 ft – 9.5 ft (2.4 m – 2.9 m)'),
              _infoRow('Weight Capacity:', 'Up to 45,000 lbs (20,412 kg)'),
              _infoRow('Common Uses:', 'General freight, packaged goods, non-perishable items.'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Go to next step/tab
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
                    // TODO: Skip action
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