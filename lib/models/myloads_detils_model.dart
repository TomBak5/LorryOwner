// To parse this JSON data, do
//
//     final myLoadsDetialsModel = myLoadsDetialsModelFromJson(jsonString);

import 'dart:convert';

MyLoadsDetialsModel myLoadsDetialsModelFromJson(String str) =>
    MyLoadsDetialsModel.fromJson(json.decode(str));

String myLoadsDetialsModelToJson(MyLoadsDetialsModel data) =>
    json.encode(data.toJson());

class MyLoadsDetialsModel {
  LoadDetails loadDetails;
  String responseCode;
  String result;
  String responseMsg;

  MyLoadsDetialsModel({
    required this.loadDetails,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory MyLoadsDetialsModel.fromJson(Map<String, dynamic> json) =>
      MyLoadsDetialsModel(
        loadDetails: LoadDetails.fromJson(json["LoadDetails"]),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "LoadDetails": loadDetails.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class LoadDetails {
  String id;
  String uid;
  String vehicleTitle;
  String vehicleImg;
  String pickupPoint;
  String dropPoint;
  String description;
  String pickLat;
  String pickLng;
  String dropLat;
  String dropLng;
  String dropStateId;
  String visibleHours;
  String pickStateId;
  String pickName;
  String pickMobile;
  String dropName;
  String dropMobile;
  String pickupState;
  String dropState;
  String amount;
  String amtType;
  String totalAmt;
  String isRate;
  String loaderName;
  String loaderImg;
  String loaderRate;
  String flowId;
  String loaderMobile;
  DateTime postDate;
  String pMethodName;
  String orderTransactionId;
  String walAmt;
  int payAmt;
  int svisibleHours;
  String hoursType;
  String materialName;
  String weight;
  String loadStatus;

  LoadDetails({
    required this.id,
    required this.uid,
    required this.vehicleTitle,
    required this.vehicleImg,
    required this.pickupPoint,
    required this.dropPoint,
    required this.description,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.dropLng,
    required this.dropStateId,
    required this.visibleHours,
    required this.pickStateId,
    required this.pickName,
    required this.pickMobile,
    required this.dropName,
    required this.dropMobile,
    required this.pickupState,
    required this.dropState,
    required this.amount,
    required this.amtType,
    required this.totalAmt,
    required this.isRate,
    required this.loaderName,
    required this.loaderImg,
    required this.loaderRate,
    required this.flowId,
    required this.loaderMobile,
    required this.postDate,
    required this.pMethodName,
    required this.orderTransactionId,
    required this.walAmt,
    required this.payAmt,
    required this.svisibleHours,
    required this.hoursType,
    required this.materialName,
    required this.weight,
    required this.loadStatus,
  });

  factory LoadDetails.fromJson(Map<String, dynamic> json) => LoadDetails(
        id: json["id"],
        uid: json["uid"],
        vehicleTitle: json["vehicle_title"],
        vehicleImg: json["vehicle_img"],
        pickupPoint: json["pickup_point"],
        dropPoint: json["drop_point"],
        description: json["description"],
        pickLat: json["pick_lat"],
        pickLng: json["pick_lng"],
        dropLat: json["drop_lat"],
        dropLng: json["drop_lng"],
        dropStateId: json["drop_state_id"],
        visibleHours: json["visible_hours"],
        pickStateId: json["pick_state_id"],
        pickName: json["pick_name"],
        pickMobile: json["pick_mobile"],
        dropName: json["drop_name"],
        dropMobile: json["drop_mobile"],
        pickupState: json["pickup_state"],
        dropState: json["drop_state"],
        amount: json["amount"],
        amtType: json["amt_type"],
        totalAmt: json["total_amt"],
        isRate: json["is_rate"],
        loaderName: json["loader_name"],
        loaderImg: json["loader_img"],
        loaderRate: json["loader_rate"],
        flowId: json["flow_id"],
        loaderMobile: json["loader_mobile"],
        postDate: DateTime.parse(json["post_date"]),
        pMethodName: json["p_method_name"],
        orderTransactionId: json["Order_Transaction_id"],
        walAmt: json["wal_amt"],
        payAmt: json["pay_amt"],
        svisibleHours: json["svisible_hours"],
        hoursType: json["hours_type"],
        materialName: json["material_name"],
        weight: json["weight"],
        loadStatus: json["load_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "vehicle_title": vehicleTitle,
        "vehicle_img": vehicleImg,
        "pickup_point": pickupPoint,
        "drop_point": dropPoint,
        "description": description,
        "pick_lat": pickLat,
        "pick_lng": pickLng,
        "drop_lat": dropLat,
        "drop_lng": dropLng,
        "drop_state_id": dropStateId,
        "visible_hours": visibleHours,
        "pick_state_id": pickStateId,
        "pick_name": pickName,
        "pick_mobile": pickMobile,
        "drop_name": dropName,
        "drop_mobile": dropMobile,
        "pickup_state": pickupState,
        "drop_state": dropState,
        "amount": amount,
        "amt_type": amtType,
        "total_amt": totalAmt,
        "is_rate": isRate,
        "loader_name": loaderName,
        "loader_img": loaderImg,
        "loader_rate": loaderRate,
        "flow_id": flowId,
        "loader_mobile": loaderMobile,
        "post_date": postDate.toIso8601String(),
        "p_method_name": pMethodName,
        "Order_Transaction_id": orderTransactionId,
        "wal_amt": walAmt,
        "pay_amt": payAmt,
        "svisible_hours": svisibleHours,
        "hours_type": hoursType,
        "material_name": materialName,
        "weight": weight,
        "load_status": loadStatus,
      };
}
