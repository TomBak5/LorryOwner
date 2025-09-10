import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../Controllers/order_controller.dart';
import '../../Controllers/homepage_controller.dart';

class AssignedOrdersScreen extends StatefulWidget {
  const AssignedOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AssignedOrdersScreen> createState() => _AssignedOrdersScreenState();
}

class _AssignedOrdersScreenState extends State<AssignedOrdersScreen> {
  final OrderController orderController = Get.put(OrderController());
  final HomePageController homePageController = Get.put(HomePageController());

  @override
  void initState() {
    super.initState();
    // Load assigned orders for current driver
    final driverId = homePageController.userData?.id ?? 'driver1';
    orderController.getAssignedOrders(driverId);
  }

  void respondToOrder(String orderId, String response) async {
    final success = await orderController.updateOrderStatus(
      orderId: orderId,
      status: response,
    );
    
    if (success) {
      // Order status updated successfully
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: Text('Assigned Orders')),
          body: orderController.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: orderController.assignedOrders.length,
                  itemBuilder: (context, index) {
                    final order = orderController.assignedOrders[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(order.details),
                        subtitle: Text('Status: ${order.status}'),
                        trailing: order.status == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => respondToOrder(order.orderId, 'accepted'),
                                    child: Text('Accept', style: TextStyle(color: Colors.green)),
                                  ),
                                  TextButton(
                                    onPressed: () => respondToOrder(order.orderId, 'rejected'),
                                    child: Text('Reject', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            : Text(order.status.capitalizeFirst ?? ''),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
} 