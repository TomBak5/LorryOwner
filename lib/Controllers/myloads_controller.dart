import 'package:get/get.dart';
import 'package:truckbuddy/models/myloads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';
import 'dart:convert';
import 'dart:async';

class MyLoadsController extends GetxController implements GetxService {
  MyLoadsModel currentData = MyLoadsModel(loadHistoryData: [], responseCode: "200", result: "true", responseMsg: "");
  MyLoadsModel complete = MyLoadsModel(loadHistoryData: [], responseCode: "200", result: "true", responseMsg: "");

  bool isLoading = true;
  String uid = '';
  String currency = "\$";
  
  // For all driver orders (including assigned, accepted, rejected, etc.)
  List<Map<String, dynamic>> assignedOrders = [];
  bool isLoadingOrders = true;
  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setDataInCurrentList(value) {
    currentData = value;
    update();
  }

  setDataInCompletList(value) {
    complete = value;
    update();
  }

  setAssignedOrders(List<Map<String, dynamic>> orders) {
    assignedOrders = orders;
    isLoadingOrders = false;
    print("=== ASSIGNED ORDERS DEBUG ===");
    print("Total orders: ${orders.length}");
    for (int i = 0; i < orders.length; i++) {
      print("Order $i: ${orders[i]}");
      if (orders[i]['route_info'] != null) {
        print("Order $i has route_info: ${orders[i]['route_info']}");
      } else {
        print("Order $i has NO route_info");
      }
    }
    print("=== END DEBUG ===");
    update();
  }

  fetchDataFromApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid")!;
    currency = prefs.getString("currencyIcon")!;

    // Reset loading states
    isLoading = true;
    isLoadingOrders = true;
    update();

    // Set a timeout for the entire loading process
    Timer(Duration(seconds: 30), () {
      if (isLoading || isLoadingOrders) {
        print('Loading timeout reached');
        setIsLoading(false);
        isLoadingOrders = false;
        update();
      }
    });

    // Fetch regular loads with timeout
    try {
      final currentLoadsFuture = ApiProvider().myLoadsApi(ownerId: uid, status: "Current");
      final currentLoads = await currentLoadsFuture.timeout(Duration(seconds: 15));
      setDataInCurrentList(currentLoads);
      
      final completedLoadsFuture = ApiProvider().myLoadsApi(ownerId: uid, status: "complet");
      final completedLoads = await completedLoadsFuture.timeout(Duration(seconds: 15));
      setDataInCompletList(completedLoads);
      setIsLoading(false);
    } catch (error) {
      print('Error fetching loads: $error');
      setDataInCurrentList(MyLoadsModel(loadHistoryData: [], responseCode: "200", result: "true", responseMsg: ""));
      setDataInCompletList(MyLoadsModel(loadHistoryData: [], responseCode: "200", result: "true", responseMsg: ""));
      setIsLoading(false);
    }

    // Fetch all driver orders (assigned, accepted, rejected, etc.) with timeout
    try {
      final apiProvider = ApiProvider();
      final ordersFuture = apiProvider.getDriverOrders(uid);
      final orders = await ordersFuture.timeout(Duration(seconds: 15));
      setAssignedOrders(orders);
    } catch (e) {
      print('Error fetching driver orders: $e');
      setAssignedOrders([]);
    }
  }
}
