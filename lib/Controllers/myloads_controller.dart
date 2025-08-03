import 'package:get/get.dart';
import 'package:movers_lorry_owner/models/myloads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';
import 'dart:convert';

class MyLoadsController extends GetxController implements GetxService {
  late MyLoadsModel currentData;
  late MyLoadsModel complete;

  bool isLoading = true;
  String uid = '';
  String currency = "\$";
  
  // For assigned orders
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
    update();
  }

  fetchDataFromApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid")!;
    currency = prefs.getString("currencyIcon")!;

    // Fetch regular loads
    ApiProvider()
        .myLoadsApi(ownerId: uid, status: "Current")
        .then((value) async {
      setDataInCurrentList(value);
      ApiProvider().myLoadsApi(ownerId: uid, status: "complet").then((value) {
        setDataInCompletList(value);
        setIsLoading(false);
      });
    });

    // Fetch assigned orders for drivers
    try {
      final apiProvider = ApiProvider();
      final orders = await apiProvider.getDriverOrders(uid);
      setAssignedOrders(orders);
    } catch (e) {
      print('Error fetching assigned orders: $e');
      setAssignedOrders([]);
    }
  }
}
