import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/order_model.dart';
import '../../Controllers/order_controller.dart';
import '../../Controllers/homepage_controller.dart';
import '../../AppConstData/app_colors.dart';
import '../../Api_Provider/api_provider.dart'; // Added import for ApiProvider
import '../../AppConstData/routes.dart'; // Added import for Routes

class MapPickerScreen extends StatefulWidget {
  final bool isPickup;
  final Function(double lat, double lng, String address) onLocationSelected;

  const MapPickerScreen({
    Key? key,
    required this.isPickup,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? mapController;
  LatLng _center = LatLng(40.7128, -74.0060); // Default to New York
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        setState(() {
          _selectedAddress = address;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Location selected';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
    });
  }

  void _onCameraIdle() {
    if (_selectedLocation != null) {
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        _selectedAddress,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup ? 'Select Pickup Location' : 'Select Drop Location'),
        backgroundColor: priMaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmLocation,
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 15.0,
                  ),
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: MarkerId('selected_location'),
                            position: _selectedLocation!,
                            infoWindow: InfoWindow(
                              title: widget.isPickup ? 'Pickup Location' : 'Drop Location',
                              snippet: _selectedAddress,
                            ),
                          ),
                        }
                      : {},
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _selectedAddress.isNotEmpty ? _selectedAddress : 'Tap and hold to select location',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Instructions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Move the map to your desired location\n• The marker will show your selected point\n• Tap "Confirm" to select this location',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class AssignOrderScreen extends StatefulWidget {
  const AssignOrderScreen({Key? key}) : super(key: key);

  @override
  State<AssignOrderScreen> createState() => _AssignOrderScreenState();
}

class _AssignOrderScreenState extends State<AssignOrderScreen> {
  // Form controllers
  final TextEditingController pickupPointController = TextEditingController();
  final TextEditingController dropPointController = TextEditingController();
  final TextEditingController materialNameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pickupNameController = TextEditingController();
  final TextEditingController pickupMobileController = TextEditingController();
  final TextEditingController dropNameController = TextEditingController();
  final TextEditingController dropMobileController = TextEditingController();

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  String? selectedDriverId; // Added driver selection
  String? selectedAmountType;
  final List<String> amountTypes = ['Per Ton', 'Per Trip', 'Fixed Amount'];

  // Location coordinates
  double? pickLat, pickLng, dropLat, dropLng;
  int? pickStateId, dropStateId;

  // Available drivers assigned to this dispatcher
  List<Map<String, dynamic>> assignedDrivers = [];
  bool isLoadingDrivers = true;

  final OrderController orderController = Get.put(OrderController());
  final HomePageController homePageController = Get.put(HomePageController());

  @override
  void initState() {
    super.initState();
    loadDrivers(); // Only load drivers now
  }

  void loadDrivers() async {
    setState(() {
      isLoadingDrivers = true;
    });
    
    try {
      final currentUserId = homePageController.userData?.id ?? 'NO_ID';
      final currentUserEmail = homePageController.userData?.email ?? 'NO_EMAIL';
      final currentUserName = homePageController.userData?.name ?? 'NO_NAME';
      
      print("=== Loading drivers for dispatcher: $currentUserId ===");
      print("=== User email: $currentUserEmail ===");
      print("=== User name: $currentUserName ===");
      print("=== Full user data: ${homePageController.userData} ===");
      
      // Use the real API to get assigned drivers
      final apiProvider = ApiProvider();
      final drivers = await apiProvider.getDispatcherAssignedDrivers(currentUserId);
      
      setState(() {
        assignedDrivers = drivers;
        isLoadingDrivers = false;
      });
      
      print("=== Loaded ${drivers.length} assigned drivers ===");
      
      // If no drivers assigned, show message
      if (drivers.isEmpty) {
        print("=== No drivers found - showing empty state ===");
        Get.snackbar(
          'No Drivers Assigned', 
          'You don\'t have any drivers assigned yet. Please contact admin or assign drivers in your profile.',
          duration: Duration(seconds: 5),
        );
      } else {
        print("=== Found ${drivers.length} drivers: ${drivers.map((d) => '${d['name']} (${d['id']})').join(', ')} ===");
      }
    } catch (e) {
      print("=== Error loading drivers: $e ===");
      setState(() {
        isLoadingDrivers = false;
      });
      
      Get.snackbar(
        'Error', 
        'Failed to load assigned drivers. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void createOrder() async {
    print("=== Starting order creation ===");
    print("=== Selected driver ID: $selectedDriverId ===");
    print("=== Selected amount type: $selectedAmountType ===");
    print("=== Form validation: ${_formKey.currentState?.validate()} ===");
    
    if (_formKey.currentState!.validate() && 
        selectedDriverId != null &&
        selectedAmountType != null) {
      
      print("=== Form validation passed ===");
      setState(() {
        isSubmitting = true;
      });

      try {
        // Calculate total amount
        double weight = double.tryParse(weightController.text) ?? 0;
        double amount = double.tryParse(amountController.text) ?? 0;
        double totalAmount = selectedAmountType == 'Per Ton' ? weight * amount : amount;

        print("=== Calculated total amount: $totalAmount ===");
        print("=== Dispatcher ID: ${homePageController.userData?.id} ===");
        print("=== Driver ID: $selectedDriverId ===");

        // Use dummy coordinates if map selection failed
        double pickupLat = pickLat ?? 40.7128;
        double pickupLng = pickLng ?? -74.0060;
        double dropLatValue = dropLat ?? 40.7589;
        double dropLngValue = dropLng ?? -73.9851;

        print("=== Calling createDispatcherOrder ===");
        final success = await orderController.createDispatcherOrder(
                      dispatcherId: homePageController.userData?.id ?? '',
            driverId: selectedDriverId!,
            vehicleId: '', // No vehicle selection, so empty string
          pickupPoint: pickupPointController.text,
          dropPoint: dropPointController.text,
          materialName: materialNameController.text,
          weight: weightController.text,
          amount: amountController.text,
          amountType: selectedAmountType!,
          totalAmount: totalAmount.toString(),
          description: descriptionController.text,
          pickupName: pickupNameController.text,
          pickupMobile: pickupMobileController.text,
          dropName: dropNameController.text,
          dropMobile: dropMobileController.text,
          pickLat: pickupLat,
          pickLng: pickupLng,
          dropLat: dropLatValue,
          dropLng: dropLngValue,
          pickStateId: pickStateId ?? 1,
          dropStateId: dropStateId ?? 1,
        );
        
        print("=== createDispatcherOrder returned: $success ===");
      
      if (success) {
          print("=== Order creation successful ===");
          Get.snackbar(
            'Success', 
            'Order created successfully! Drivers will be notified.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          // Clear form with null checks
          try {
            _formKey.currentState?.reset();
            pickupPointController.clear();
            dropPointController.clear();
            materialNameController.clear();
            weightController.clear();
            amountController.clear();
            descriptionController.clear();
            pickupNameController.clear();
            pickupMobileController.clear();
            dropNameController.clear();
            dropMobileController.clear();
            setState(() {
              selectedDriverId = null;
              selectedAmountType = null;
              pickLat = pickLng = dropLat = dropLng = null;
              pickStateId = dropStateId = null;
            });
          } catch (e) {
            print("=== Error clearing form: $e ===");
          }
          
          // Wait a moment for the success message to be visible, then go back to main page
          await Future.delayed(Duration(seconds: 2));
          // Navigate back to home page explicitly
          Get.offAllNamed(Routes.landingPage);
        } else {
          print("=== Order creation failed (success = false) ===");
          Get.snackbar(
            'Error', 
            'Failed to create order: API returned false',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print("=== Exception during order creation: $e ===");
        Get.snackbar(
          'Error', 
          'Failed to create order: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    } else {
      print("=== Form validation failed ===");
      print("=== selectedDriverId: $selectedDriverId ===");
      print("=== selectedAmountType: $selectedAmountType ===");
      
      String errorMessage = '';
      if (selectedDriverId == null) {
        errorMessage = 'Please select a driver';
      } else if (selectedAmountType == null) {
        errorMessage = 'Please select amount type';
      } else {
        errorMessage = 'Please fill all required fields';
      }
      
      Get.snackbar(
        'Validation Error', 
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void selectLocation(bool isPickup) {
    // Show simple location input dialog instead of crashing map
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final locationController = TextEditingController();
        return AlertDialog(
          title: Text(isPickup ? 'Enter Pickup Location' : 'Enter Drop Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter location manually:'),
              SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location Address',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 123 Main St, New York, NY',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (locationController.text.isNotEmpty) {
                  // Set dummy coordinates and address
                  if (isPickup) {
                    pickLat = 40.7128;
                    pickLng = -74.0060;
                    pickupPointController.text = locationController.text;
                  } else {
                    dropLat = 40.7589;
                    dropLng = -73.9851;
                    dropPointController.text = locationController.text;
                  }
                  setState(() {});
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Location Set', 
                    'Location entered successfully',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text('Set Location'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Order'),
        backgroundColor: priMaryColor,
        foregroundColor: Colors.white,
      ),
      body: isSubmitting 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Driver Selection
                  Text(
                    'Select Driver',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  isLoadingDrivers
                  ? Center(child: CircularProgressIndicator())
                  : assignedDrivers.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'No Drivers Assigned',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You don\'t have any drivers assigned yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to driver assignment screen
                              Get.toNamed('/LinkDriverScreen');
                            },
                            child: Text('Assign Drivers'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedDriverId,
                        decoration: InputDecoration(
                          labelText: 'Select Driver',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: assignedDrivers.map((driver) {
                          String displayName = driver['name'] ?? 'Unknown Driver';
                          String email = driver['email'] ?? '';
                          String mobile = driver['mobile'] ?? '';
                          
                          String displayText = '$displayName';
                          if (email.isNotEmpty) {
                            displayText += ' ($email)';
                          }
                          if (mobile.isNotEmpty) {
                            displayText += ' - $mobile';
                          }
                          
                          return DropdownMenuItem<String>(
                            value: driver['id']?.toString(),
                            child: Text(displayText),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDriverId = value;
                          });
                          print("=== Selected driver ID: $value ===");
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a driver';
                          }
                          return null;
                        },
                      ),
                    ),
                  SizedBox(height: 16),

                  // Pickup Details
                  Text(
                    'Pickup Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: pickupPointController,
                          decoration: InputDecoration(
                            labelText: 'Pickup Location',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter pickup location' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => selectLocation(true),
                        child: Text('Map'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: pickupNameController,
                          decoration: InputDecoration(
                            labelText: 'Contact Name (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: pickupMobileController,
                          decoration: InputDecoration(
                            labelText: 'Contact Mobile (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Drop Details
                  Text(
                    'Drop Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dropPointController,
                          decoration: InputDecoration(
                            labelText: 'Drop Location',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter drop location' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => selectLocation(false),
                        child: Text('Map'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dropNameController,
                          decoration: InputDecoration(
                            labelText: 'Contact Name (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: dropMobileController,
                          decoration: InputDecoration(
                            labelText: 'Contact Mobile (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Material Details
                  Text(
                    'Material Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: materialNameController,
                    decoration: InputDecoration(
                      labelText: 'Material Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter material name' : null,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: weightController,
                          decoration: InputDecoration(
                            labelText: 'Weight (in tons)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Enter weight' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedAmountType,
                          decoration: InputDecoration(
                            labelText: 'Amount Type',
                            border: OutlineInputBorder(),
                          ),
                          items: amountTypes.map((type) {
                        return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                              selectedAmountType = value;
                        });
                      },
                          validator: (value) => value == null ? 'Select amount type' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 32),

                  // Submit Button
              SizedBox(
                width: double.infinity,
                    height: 50,
                child: ElevatedButton(
                      onPressed: createOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: priMaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Create Order',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 