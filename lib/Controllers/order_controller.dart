import 'package:get/get.dart';
import '../Api_Provider/api_provider.dart';
import '../models/order_model.dart';
import 'dart:convert'; // Added for jsonDecode

class OrderController extends GetxController implements GetxService {
  bool isLoading = false;
  List<OrderModel> assignedOrders = [];

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  // Assign order from dispatcher to driver
  Future assignOrder({
    required String dispatcherId,
    required String driverId,
    required String details,
  }) async {
    setIsLoading(true);
    try {
      // For testing, use mock response
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
      // Mock successful response
      Get.snackbar('Success', 'Order assigned successfully!');
      return true;
      
      // Uncomment when backend is ready:
      // final response = await ApiProvider().assignOrderApi(
      //   dispatcherId: dispatcherId,
      //   driverId: driverId,
      //   details: details,
      // );
      // 
      // if (response["Result"] == "true") {
      //   Get.snackbar('Success', 'Order assigned successfully!');
      //   return true;
      // } else {
      //   Get.snackbar('Error', response["ResponseMsg"] ?? 'Failed to assign order');
      //   return false;
      // }
    } catch (e) {
      Get.snackbar('Error', 'Network error occurred');
      return false;
    } finally {
      setIsLoading(false);
    }
  }

  // Get assigned orders for a driver
  Future getAssignedOrders(String driverId) async {
    setIsLoading(true);
    try {
      final apiProvider = ApiProvider();
      final orders = await apiProvider.getDriverOrders(driverId);
      
      // Convert API response to OrderModel objects
      assignedOrders = orders.map((order) => OrderModel(
        orderId: order['id'].toString(),
        dispatcherId: order['dispatcher_id'].toString(),
        driverId: order['driver_id'].toString(),
        status: order['status'] ?? 'pending',
        details: _formatOrderDetails(order),
        createdAt: DateTime.parse(order['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(order['updated_at'] ?? DateTime.now().toIso8601String()),
      )).toList();
      
      update();
      return true;
    } catch (e) {
      print('Error loading assigned orders: $e');
      Get.snackbar('Error', 'Failed to load orders');
      return false;
    } finally {
      setIsLoading(false);
    }
  }

  // Format order details from cargo_details JSON
  String _formatOrderDetails(Map<String, dynamic> order) {
    try {
      final cargoDetails = jsonDecode(order['cargo_details'] ?? '{}');
      return '${cargoDetails['pickup_name'] ?? 'Unknown'} → ${cargoDetails['drop_name'] ?? 'Unknown'}\n'
             'Material: ${cargoDetails['material_name'] ?? 'N/A'}\n'
             'Weight: ${cargoDetails['weight'] ?? 'N/A'} kg\n'
             'Amount: ${cargoDetails['total_amount'] ?? 'N/A'}';
    } catch (e) {
      return 'Order ${order['id']} - ${order['pickup_address'] ?? 'Unknown'} to ${order['dropoff_address'] ?? 'Unknown'}';
    }
  }

  // Update order status (accept/reject)
  Future updateOrderStatus({
    required String orderId,
    required String status,
    String? comment,
  }) async {
    setIsLoading(true);
    try {
      final apiProvider = ApiProvider();
      final result = await apiProvider.updateOrderStatus(
        orderId: orderId,
        status: status,
        comment: comment,
      );
      
      if (result['success'] == true) {
        // Update local order status
        final orderIndex = assignedOrders.indexWhere((order) => order.orderId == orderId);
        if (orderIndex != -1) {
          assignedOrders[orderIndex] = OrderModel(
            orderId: assignedOrders[orderIndex].orderId,
            dispatcherId: assignedOrders[orderIndex].dispatcherId,
            driverId: assignedOrders[orderIndex].driverId,
            status: status,
            details: assignedOrders[orderIndex].details,
            createdAt: assignedOrders[orderIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          update();
        }
        
        Get.snackbar('Success', 'Order ${status} successfully!');
        return true;
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to update order');
        return false;
      }
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar('Error', 'Network error occurred');
      return false;
    } finally {
      setIsLoading(false);
    }
  }

  // Create new order by dispatcher
  Future createDispatcherOrder({
    required String dispatcherId,
    required String driverId,
    required String vehicleId,
    required String pickupPoint,
    required String dropPoint,
    required String materialName,
    required String weight,
    required String amount,
    required String amountType,
    required String totalAmount,
    required String description,
    required String pickupName,
    required String pickupMobile,
    required String dropName,
    required String dropMobile,
    required double pickLat,
    required double pickLng,
    required double dropLat,
    required double dropLng,
    required int pickStateId,
    required int dropStateId,
  }) async {
    setIsLoading(true);
    try {
      print("=== Creating dispatcher order with driver: $driverId ===");
      
      final response = await ApiProvider().createDispatcherOrderApi(
        dispatcherId: dispatcherId,
        driverId: driverId,
        vehicleId: vehicleId,
        pickupPoint: pickupPoint,
        dropPoint: dropPoint,
        materialName: materialName,
        weight: weight,
        amount: amount,
        amountType: amountType,
        totalAmount: totalAmount,
        description: description,
        pickupName: pickupName,
        pickupMobile: pickupMobile,
        dropName: dropName,
        dropMobile: dropMobile,
        pickLat: pickLat,
        pickLng: pickLng,
        dropLat: dropLat,
        dropLng: dropLng,
        pickStateId: pickStateId,
        dropStateId: dropStateId,
      );
      
      print("=== API Response: $response ===");
      
      if (response["Result"] == "true") {
        Get.snackbar('Success', 'Order created successfully! Driver will be notified.');
        return true;
      } else {
        Get.snackbar('Error', response["ResponseMsg"] ?? 'Failed to create order');
        return false;
      }
    } catch (e) {
      print("=== Error creating order: $e ===");
      Get.snackbar('Error', 'Network error occurred while creating order');
      return false;
    } finally {
      setIsLoading(false);
    }
  }
} 
