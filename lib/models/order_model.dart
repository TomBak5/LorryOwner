class OrderModel {
  final String orderId;
  final String dispatcherId;
  final String driverId;
  final String status;
  final String details;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.orderId,
    required this.dispatcherId,
    required this.driverId,
    required this.status,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
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
    };
  }
} 