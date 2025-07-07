// To parse this JSON data, do
//
//     final myLoads = myLoadsFromJson(jsonString);

import 'dart:convert';

MyLoadsModel myLoadsFromJson(String str) =>
    MyLoadsModel.fromJson(json.decode(str));

String myLoadsToJson(MyLoadsModel data) => json.encode(data.toJson());

class MyLoadsModel {
  List<LoadHistoryDatum> loadHistoryData;
  String responseCode;
  String result;
  String responseMsg;

  MyLoadsModel({
    required this.loadHistoryData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory MyLoadsModel.fromJson(Map<String, dynamic> json) => MyLoadsModel(
        loadHistoryData: List<LoadHistoryDatum>.from(
            json["LoadHistoryData"].map((x) => LoadHistoryDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "LoadHistoryData":
            List<dynamic>.from(loadHistoryData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class LoadHistoryDatum {
  String id;
  String vehicleTitle;
  String vehicleImg;
  String pickupPoint;
  String dropPoint;
  String pickupState;
  String dropState;
  String amount;
  String amtType;
  String totalAmt;
  DateTime postDate;
  String loadStatus;
  String loadDistance;
  int svisibleHours;

  LoadHistoryDatum({
    required this.id,
    required this.vehicleTitle,
    required this.vehicleImg,
    required this.pickupPoint,
    required this.dropPoint,
    required this.pickupState,
    required this.dropState,
    required this.amount,
    required this.amtType,
    required this.totalAmt,
    required this.postDate,
    required this.loadStatus,
    required this.loadDistance,
    required this.svisibleHours,
  });

  factory LoadHistoryDatum.fromJson(Map<String, dynamic> json) =>
      LoadHistoryDatum(
        id: json["id"],
        vehicleTitle: json["vehicle_title"],
        vehicleImg: json["vehicle_img"],
        pickupPoint: json["pickup_point"],
        dropPoint: json["drop_point"],
        pickupState: json["pickup_state"],
        dropState: json["drop_state"],
        amount: json["amount"],
        amtType: json["amt_type"],
        totalAmt: json["total_amt"],
        postDate: DateTime.parse(json["post_date"]),
        loadStatus: json["load_status"],
        loadDistance: json["load_distance"],
        svisibleHours: json["svisible_hours"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_title": vehicleTitle,
        "vehicle_img": vehicleImg,
        "pickup_point": pickupPoint,
        "drop_point": dropPoint,
        "pickup_state": pickupState,
        "drop_state": dropState,
        "amount": amount,
        "amt_type": amtType,
        "total_amt": totalAmt,
        "post_date": postDate.toIso8601String(),
        "load_status": loadStatus,
        "load_distance": loadDistance,
        "svisible_hours": svisibleHours,
      };
}
