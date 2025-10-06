class OrderModel {
  final String orderId;
  final String dispatcherId;
  final String driverId;
  final String status;
  final String details;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTruckId;  // Add truck assignment
  final String? assignedTruckNo;  // Add truck number for display
  final String? assignedTruckTitle; // Add truck title for display

  OrderModel({
    required this.orderId,
    required this.dispatcherId,
    required this.driverId,
    required this.status,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTruckId,
    this.assignedTruckNo,
    this.assignedTruckTitle,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'],
      dispatcherId: json['dispatcher_id'],
      driverId: json['driver_id'],
      status: json['status'],
      details: json['details'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      assignedTruckId: json['assigned_truck_id'],
      assignedTruckNo: json['assigned_truck_no'],
      assignedTruckTitle: json['assigned_truck_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'dispatcher_id': dispatcherId,
      'driver_id': driverId,
      'status': status,
      'details': details,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assigned_truck_id': assignedTruckId,
      'assigned_truck_no': assignedTruckNo,
      'assigned_truck_title': assignedTruckTitle,
    };
  }
} 
