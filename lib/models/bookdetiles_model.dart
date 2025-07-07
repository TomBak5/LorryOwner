// To parse this JSON data, do
//
//     final bookedDetialsModel = bookedDetialsModelFromJson(jsonString);

import 'dart:convert';

BookedDetialsModel bookedDetialsModelFromJson(String str) =>
    BookedDetialsModel.fromJson(json.decode(str));

String bookedDetialsModelToJson(BookedDetialsModel data) =>
    json.encode(data.toJson());

class BookedDetialsModel {
  LoadDetails loadDetails;
  String responseCode;
  String result;
  String responseMsg;

  BookedDetialsModel({
    required this.loadDetails,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory BookedDetialsModel.fromJson(Map<String, dynamic> json) =>
      BookedDetialsModel(
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
  String uid;
  String loaderName;
  String loaderImg;
  String lorryNumber;
  String loaderMobile;
  String loaderRate;
  String offerDescription;
  String offerPrice;
  String offerBy;
  String offerType;
  String offerTotal;
  String id;
  String vehicleTitle;
  String vehicleImg;
  String pickupPoint;
  String dropPoint;
  String isAccept;
  String flowId;
  String pMethodName;
  dynamic orderTransactionId;
  String walAmt;
  String description;
  String pickLat;
  String pickLng;
  String dropLat;
  String isRate;
  String dropLng;
  String dropStateId;
  String visibleHours;
  String pickStateId;
  String pickupState;
  String dropState;
  String amount;
  String pickName;
  String pickMobile;
  String dropName;
  String dropMobile;
  String amtType;
  String totalAmt;
  int payAmt;
  DateTime postDate;
  String commentReject;
  String materialName;
  String weight;
  String loadStatus;

  LoadDetails({
    required this.uid,
    required this.loaderName,
    required this.loaderImg,
    required this.lorryNumber,
    required this.loaderMobile,
    required this.loaderRate,
    required this.offerDescription,
    required this.offerPrice,
    required this.offerBy,
    required this.offerType,
    required this.offerTotal,
    required this.id,
    required this.vehicleTitle,
    required this.vehicleImg,
    required this.pickupPoint,
    required this.dropPoint,
    required this.isAccept,
    required this.flowId,
    required this.pMethodName,
    required this.orderTransactionId,
    required this.walAmt,
    required this.description,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.isRate,
    required this.dropLng,
    required this.dropStateId,
    required this.visibleHours,
    required this.pickStateId,
    required this.pickupState,
    required this.dropState,
    required this.amount,
    required this.pickName,
    required this.pickMobile,
    required this.dropName,
    required this.dropMobile,
    required this.amtType,
    required this.totalAmt,
    required this.payAmt,
    required this.postDate,
    required this.commentReject,
    required this.materialName,
    required this.weight,
    required this.loadStatus,
  });

  factory LoadDetails.fromJson(Map<String, dynamic> json) => LoadDetails(
        uid: json["uid"],
        loaderName: json["loader_name"],
        loaderImg: json["loader_img"],
        lorryNumber: json["lorry_number"],
        loaderMobile: json["loader_mobile"],
        loaderRate: json["loader_rate"],
        offerDescription: json["offer_description"],
        offerPrice: json["offer_price"],
        offerBy: json["offer_by"],
        offerType: json["offer_type"],
        offerTotal: json["offer_total"],
        id: json["id"],
        vehicleTitle: json["vehicle_title"],
        vehicleImg: json["vehicle_img"],
        pickupPoint: json["pickup_point"],
        dropPoint: json["drop_point"],
        isAccept: json["is_accept"],
        flowId: json["flow_id"],
        pMethodName: json["p_method_name"],
        orderTransactionId: json["Order_Transaction_id"] ?? "",
        walAmt: json["wal_amt"],
        description: json["description"],
        pickLat: json["pick_lat"],
        pickLng: json["pick_lng"],
        dropLat: json["drop_lat"],
        isRate: json["is_rate"],
        dropLng: json["drop_lng"],
        dropStateId: json["drop_state_id"],
        visibleHours: json["visible_hours"],
        pickStateId: json["pick_state_id"],
        pickupState: json["pickup_state"],
        dropState: json["drop_state"],
        amount: json["amount"],
        pickName: json["pick_name"],
        pickMobile: json["pick_mobile"],
        dropName: json["drop_name"],
        dropMobile: json["drop_mobile"],
        amtType: json["amt_type"],
        totalAmt: json["total_amt"],
        payAmt: json["pay_amt"],
        postDate: DateTime.parse(json["post_date"]),
        commentReject: json["comment_reject"],
        materialName: json["material_name"],
        weight: json["weight"],
        loadStatus: json["load_status"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "loader_name": loaderName,
        "loader_img": loaderImg,
        "lorry_number": lorryNumber,
        "loader_mobile": loaderMobile,
        "loader_rate": loaderRate,
        "offer_description": offerDescription,
        "offer_price": offerPrice,
        "offer_by": offerBy,
        "offer_type": offerType,
        "offer_total": offerTotal,
        "id": id,
        "vehicle_title": vehicleTitle,
        "vehicle_img": vehicleImg,
        "pickup_point": pickupPoint,
        "drop_point": dropPoint,
        "is_accept": isAccept,
        "flow_id": flowId,
        "p_method_name": pMethodName,
        "Order_Transaction_id": orderTransactionId,
        "wal_amt": walAmt,
        "description": description,
        "pick_lat": pickLat,
        "pick_lng": pickLng,
        "drop_lat": dropLat,
        "is_rate": isRate,
        "drop_lng": dropLng,
        "drop_state_id": dropStateId,
        "visible_hours": visibleHours,
        "pick_state_id": pickStateId,
        "pickup_state": pickupState,
        "drop_state": dropState,
        "amount": amount,
        "pick_name": pickName,
        "pick_mobile": pickMobile,
        "drop_name": dropName,
        "drop_mobile": dropMobile,
        "amt_type": amtType,
        "total_amt": totalAmt,
        "pay_amt": payAmt,
        "post_date": postDate.toIso8601String(),
        "comment_reject": commentReject,
        "material_name": materialName,
        "weight": weight,
        "load_status": loadStatus,
      };
}
