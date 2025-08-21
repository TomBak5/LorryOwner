import 'package:get/get.dart';
import 'package:movers_lorry_owner/models/myloads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';
import 'dart:convert';

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

    // Fetch regular loads
    ApiProvider()
        .myLoadsApi(ownerId: uid, status: "Current")
        .then((value) async {
      setDataInCurrentList(value);
      ApiProvider().myLoadsApi(ownerId: uid, status: "complet").then((value) {
        setDataInCompletList(value);
        setIsLoading(false);
      }).catchError((error) {
        print('Error fetching completed loads: $error');
        setIsLoading(false);
      });
    }).catchError((error) {
      print('Error fetching current loads: $error');
      setDataInCurrentList(MyLoadsModel(loadHistoryData: [], responseCode: "200", result: "true", responseMsg: ""));
      setIsLoading(false);
    });

    // Fetch all driver orders (assigned, accepted, rejected, etc.)
    try {
      final apiProvider = ApiProvider();
      final orders = await apiProvider.getDriverOrders(uid);
      setAssignedOrders(orders);
    } catch (e) {
      print('Error fetching driver orders: $e');
      setAssignedOrders([]);
    }
  }
}
