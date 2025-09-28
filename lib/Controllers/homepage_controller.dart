import 'dart:convert';

import 'package:get/get.dart';
import 'package:movers_lorry_owner/models/home_model.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';
import '../models/login_model.dart';
import 'package:flutter/foundation.dart';

class HomePageController extends GetxController implements GetxService {
  UserLogin? userData;
  HomeModel? homePageData;
  List<Map<String, dynamic>> assignedTrucks = []; // Add assigned trucks list

  List menuList = [
    "Find Loads",
    "Near Load",
    "Attach Lorry",
    "My Orders",
    "Fuel"
  ];

  List dispatcherMenuList = [
    "Create Order",
    "Manage Drivers",
    "Order History",
    "Dashboard"
  ];

  // Add method to get assigned trucks for current driver
  Future<void> getAssignedTrucks() async {
    if (userData?.id == null) {
      print('❌ getAssignedTrucks: userData?.id is null');
      return;
    }
    
    print('🚛 getAssignedTrucks: Starting for driver ID: ${userData!.id}');
    print('🚛 getAssignedTrucks: User role: ${userData?.userRole}');
    
    try {
      var response = await ApiProvider().getAssignedTrucks(driverId: userData!.id!);
      print('🚛 getAssignedTrucks: API response received: $response');
      
      if (response['Result'] == 'true' && response['AssignedTrucks'] != null) {
        assignedTrucks = List<Map<String, dynamic>>.from(response['AssignedTrucks']);
        print('🚛 getAssignedTrucks: Success! Found ${assignedTrucks.length} assigned trucks');
        print('🚛 getAssignedTrucks: Truck data: $assignedTrucks');
      } else {
        print('🚛 getAssignedTrucks: API returned false or no trucks');
        print('🚛 getAssignedTrucks: Response: $response');
        assignedTrucks = [];
      }
      
      print('🚛 getAssignedTrucks: Final assignedTrucks count: ${assignedTrucks.length}');
      print('🚛 getAssignedTrucks: hasAssignedTruck will return: ${assignedTrucks.isNotEmpty}');
      
      update();
    } catch (e) {
      print('❌ getAssignedTrucks: Error occurred: $e');
      assignedTrucks = [];
      update();
    }
  }

  // Get assigned truck for current driver
  Map<String, dynamic>? getCurrentAssignedTruck() {
    if (assignedTrucks.isEmpty) return null;
    
    // Get the first assigned truck
    var truck = assignedTrucks.first;
    
    // Add sample data for testing if fields are missing
    if (truck['truck_brand'] == null) {
      truck['truck_brand'] = 'Volvo';
    }
    if (truck['truck_model'] == null) {
      truck['truck_model'] = 'FH16';
    }
    if (truck['truck_year'] == null) {
      truck['truck_year'] = '2022';
    }
    if (truck['truck_engine'] == null) {
      truck['truck_engine'] = '16L Diesel';
    }
    if (truck['truck_transmission'] == null) {
      truck['truck_transmission'] = '12-Speed Manual';
    }
    
    return truck;
  }

  // Get truck specifications with fallback values
  Map<String, String> getTruckSpecifications() {
    final truck = getCurrentAssignedTruck();
    if (truck == null) return {};
    
    return {
      'brand': truck['truck_brand'] ?? truck['brand'] ?? 'Brand',
      'model': truck['truck_model'] ?? truck['model'] ?? 'Model',
      'year': truck['truck_year'] ?? truck['year'] ?? 'Year',
      'engine': truck['truck_engine'] ?? truck['engine'] ?? 'Engine',
      'transmission': truck['truck_transmission'] ?? truck['transmission'] ?? 'Transmission',
    };
  }

  // Check if driver has assigned truck
  bool get hasAssignedTruck => assignedTrucks.isNotEmpty;

  updateUserProfile(context) {
    ApiProvider().loginUser(
            code: userData?.ccode ?? '',
            number: userData?.mobile ?? '',
            password: userData?.password ?? '')
        .then((value) async {
      var data = value;
      if (data["Result"] == "true") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String decodeData = jsonEncode(data["UserLogin"]);
        await prefs.setString("userData", decodeData);
        getDataFromLocalData().then((value) {
          if (value.toString().isNotEmpty) {
            setIcon(verification12(userData?.isVerify ?? ''));
            getHomePageData(uid: userData?.id ?? '');
          }
        });
      } else {
        if ((data["ResponseMsg"] ?? "").trim().isNotEmpty) {
          showCommonToast(data["ResponseMsg"]);
        }
      }
    });
  }

  verification12(String id) {
    switch (id) {
      case "0":
        return "assets/icons/alert-circle.svg";
      case "1":
        return "assets/icons/ic_document_process.svg";
      case "2":
        return "assets/icons/badge-check.svg";
      default:
        return "assets/icons/alert-circle.svg";
    }
  }

  String? verification;

  bool isLoading = true;

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setIcon(String value) {
    verification = value;
    update();
  }

  Future getDataFromLocalData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedMap = prefs.getString('userData');

    if (encodedMap!.isNotEmpty) {
      var decodedata = jsonDecode(encodedMap);
      userData = UserLogin.fromJson(decodedata);

      prefs.setString("uid", userData?.id ?? '');

      update();
    }
    
    // Always set loading to false after checking local data
    setIsLoading(false);
  }

  Future<void> getHomePageData({required String uid}) async {
    setIsLoading(true); // Start loading
    var response = await ApiProvider().homePageApi(uid: uid);
    debugPrint('homePageApi response:');
    debugPrint(response.toString());
    if (response == null || response is! Map || response['error'] != null) {
      showCommonToast('Failed to load home page data.');
      setIsLoading(false); // Always stop loading on error
      return;
    }
    if (response['Result'] == 'true' && response['HomeData'] != null) {
      homePageData = HomeModel.fromJson(Map<String, dynamic>.from(response));
      update();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("wallet", homePageData?.homeData?.currency ?? "");
      prefs.setString("currencyIcon", homePageData?.homeData?.currency ?? "");
      prefs.setString("gkey", homePageData?.homeData?.gKey ?? "");
      update();
      setIsLoading(false); // Stop loading on success
    } else {
      if ((response['ResponseMsg']?.toString() ?? '').trim().isNotEmpty) {
        // Removed: showCommonToast(response['ResponseMsg']?.toString());
      }
      setIsLoading(false); // Stop loading on backend error
    }
  }

  removeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userData", "");
    prefs.setString("currencyIcon", "");
    prefs.setString("uid", "");
  }
}
