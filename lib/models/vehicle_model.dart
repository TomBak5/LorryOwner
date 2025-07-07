// To parse this JSON data, do
//
//     final vehicleListModel = vehicleListModelFromJson(jsonString);

import 'dart:convert';

VehicleListModel vehicleListModelFromJson(String str) =>
    VehicleListModel.fromJson(json.decode(str));

String vehicleListModelToJson(VehicleListModel data) =>
    json.encode(data.toJson());

class VehicleListModel {
  List<VehicleDatum> vehicleData;
  String responseCode;
  String result;
  String responseMsg;

  VehicleListModel({
    required this.vehicleData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory VehicleListModel.fromJson(Map<String, dynamic> json) =>
      VehicleListModel(
        vehicleData: List<VehicleDatum>.from(
            json["VehicleData"].map((x) => VehicleDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "VehicleData": List<dynamic>.from(vehicleData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class VehicleDatum {
  String id;
  String title;
  String img;
  String minWeight;
  String maxWeight;
  String status;

  VehicleDatum({
    required this.id,
    required this.title,
    required this.img,
    required this.minWeight,
    required this.maxWeight,
    required this.status,
  });

  factory VehicleDatum.fromJson(Map<String, dynamic> json) => VehicleDatum(
        id: json["id"],
        title: json["title"],
        img: json["img"],
        minWeight: json["min_weight"],
        maxWeight: json["max_weight"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img": img,
        "min_weight": minWeight,
        "max_weight": maxWeight,
        "status": status,
      };
}
