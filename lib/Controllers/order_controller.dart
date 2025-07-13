import 'package:get/get.dart';
import '../Api_Provider/api_provider.dart';
import '../models/order_model.dart';

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
      // For testing, use mock data
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
      // Mock assigned orders
      assignedOrders = [
        OrderModel(
          orderId: '1',
          dispatcherId: 'dispatcher1',
          driverId: driverId,
          status: 'pending',
          details: 'Pickup at A, drop at B - $driverId',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        OrderModel(
          orderId: '2',
          dispatcherId: 'dispatcher1',
          driverId: driverId,
          status: 'pending',
          details: 'Pickup at C, drop at D - $driverId',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        ),
      ];
      update();
      return true;
      
      // Uncomment when backend is ready:
      // final response = await ApiProvider().getAssignedOrdersApi(driverId: driverId);
      // 
      // if (response["Result"] == "true") {
      //   assignedOrders = (response["Orders"] as List)
      //       .map((order) => OrderModel.fromJson(order))
      //       .toList();
      //   update();
      //   return true;
      // } else {
      //   Get.snackbar('Error', response["ResponseMsg"] ?? 'Failed to load orders');
      //   return false;
      // }
    } catch (e) {
      Get.snackbar('Error', 'Network error occurred');
      return false;
    } finally {
      setIsLoading(false);
    }
  }

  // Update order status (accept/reject)
  Future updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    setIsLoading(true);
    try {
      // For testing, use mock response
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
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
      
      // Uncomment when backend is ready:
      // final response = await ApiProvider().updateOrderStatusApi(
      //   orderId: orderId,
      //   status: status,
      // );
      // 
      // if (response["Result"] == "true") {
      //   // Update local order status
      //   final orderIndex = assignedOrders.indexWhere((order) => order.orderId == orderId);
      //   if (orderIndex != -1) {
      //     assignedOrders[orderIndex] = OrderModel(
      //       orderId: assignedOrders[orderIndex].orderId,
      //       dispatcherId: assignedOrders[orderIndex].dispatcherId,
      //       driverId: assignedOrders[orderIndex].driverId,
      //       status: status,
      //       details: assignedOrders[orderIndex].details,
      //       createdAt: assignedOrders[orderIndex].createdAt,
      //       updatedAt: DateTime.now(),
      //     );
      //     update();
      //   }
      //   
      //   Get.snackbar('Success', 'Order ${status} successfully!');
      //   return true;
      // } else {
      //   Get.snackbar('Error', response["ResponseMsg"] ?? 'Failed to update order');
      //   return false;
      // }
    } catch (e) {
      Get.snackbar('Error', 'Network error occurred');
      return false;
    } finally {
      setIsLoading(false);
    }
  }
} 