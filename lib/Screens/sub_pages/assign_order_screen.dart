import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../Controllers/order_controller.dart';
import '../../Controllers/homepage_controller.dart';

class AssignOrderScreen extends StatefulWidget {
  const AssignOrderScreen({Key? key}) : super(key: key);

  @override
  State<AssignOrderScreen> createState() => _AssignOrderScreenState();
}

class _AssignOrderScreenState extends State<AssignOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController detailsController = TextEditingController();
  String? selectedDriverId;
  final OrderController orderController = Get.put(OrderController());
  final HomePageController homePageController = Get.put(HomePageController());

  // Real driver list - will be populated from API
  List<Map<String, String>> drivers = [];
  bool isLoadingDrivers = true;

  @override
  void initState() {
    super.initState();
    loadDrivers();
  }

  void loadDrivers() async {
    setState(() {
      isLoadingDrivers = true;
    });
    
    // For now, use mock data. In real implementation, fetch from API
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      drivers = [
        {'id': 'driver1', 'name': 'John Doe'},
        {'id': 'driver2', 'name': 'Jane Smith'},
        {'id': 'driver3', 'name': 'Alex Johnson'},
      ];
      isLoadingDrivers = false;
    });
  }

  void assignOrder() async {
    if (_formKey.currentState!.validate() && selectedDriverId != null) {
      final success = await orderController.assignOrder(
        dispatcherId: homePageController.userData?.id ?? 'dispatcher1',
        driverId: selectedDriverId!,
        details: detailsController.text,
      );
      
      if (success) {
        // Clear form
        detailsController.clear();
        setState(() {
          selectedDriverId = null;
        });
      }
    } else {
      Get.snackbar('Error', 'Please fill all fields and select a driver.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: detailsController,
                decoration: InputDecoration(labelText: 'Order Details'),
                validator: (value) => value == null || value.isEmpty ? 'Enter order details' : null,
              ),
              SizedBox(height: 16),
              isLoadingDrivers
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedDriverId,
                      decoration: InputDecoration(labelText: 'Select Driver'),
                      items: drivers.map((driver) {
                        return DropdownMenuItem<String>(
                          value: driver['id'],
                          child: Text(driver['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDriverId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Select a driver' : null,
                    ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: assignOrder,
                  child: Text('Assign Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 