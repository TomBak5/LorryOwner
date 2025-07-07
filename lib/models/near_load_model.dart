// To parse this JSON data, do
//
//     final nearLoadModel = nearLoadModelFromJson(jsonString);

import 'dart:convert';

NearLoadModel nearLoadModelFromJson(String str) =>
    NearLoadModel.fromJson(json.decode(str));

String nearLoadModelToJson(NearLoadModel data) => json.encode(data.toJson());

class NearLoadModel {
  List<Loaddatum> loaddata;
  String responseCode;
  String result;
  String responseMsg;

  NearLoadModel({
    required this.loaddata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory NearLoadModel.fromJson(Map<String, dynamic> json) => NearLoadModel(
        loaddata: List<Loaddatum>.from(
            json["loaddata"].map((x) => Loaddatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "loaddata": List<dynamic>.from(loaddata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Loaddatum {
  String id;
  String uid;
  String vehicleTitle;
  String vehicleImg;
  String pickupPoint;
  String dropPoint;
  String pickupState;
  String dropState;
  String amount;
  String weight;
  String amtType;
  String totalAmt;
  DateTime postDate;
  String loadStatus;
  String ownerName;
  String ownerImg;
  String materialName;
  String loadDistance;
  String ownerRating;
  String bidAmount;
  String bidAmountType;
  String bidTotalAmt;
  int isBid;

  Loaddatum({
    required this.id,
    required this.uid,
    required this.vehicleTitle,
    required this.vehicleImg,
    required this.pickupPoint,
    required this.dropPoint,
    required this.pickupState,
    required this.dropState,
    required this.amount,
    required this.weight,
    required this.amtType,
    required this.totalAmt,
    required this.postDate,
    required this.loadStatus,
    required this.ownerName,
    required this.ownerImg,
    required this.materialName,
    required this.loadDistance,
    required this.ownerRating,
    required this.bidAmount,
    required this.bidAmountType,
    required this.bidTotalAmt,
    required this.isBid,
  });

  factory Loaddatum.fromJson(Map<String, dynamic> json) => Loaddatum(
        id: json["id"],
        uid: json["uid"],
        vehicleTitle: json["vehicle_title"],
        vehicleImg: json["vehicle_img"],
        pickupPoint: json["pickup_point"],
        dropPoint: json["drop_point"],
        pickupState: json["pickup_state"],
        dropState: json["drop_state"],
        amount: json["amount"],
        weight: json["weight"],
        amtType: json["amt_type"],
        totalAmt: json["total_amt"],
        postDate: DateTime.parse(json["post_date"]),
        loadStatus: json["load_status"],
        ownerName: json["owner_name"],
        ownerImg: json["owner_img"],
        materialName: json["material_name"],
        loadDistance: json["load_distance"],
        ownerRating: json["owner_rating"],
        bidAmount: json["bid_amount"],
        bidAmountType: json["bid_amount_type"],
        bidTotalAmt: json["bid_total_amt"],
        isBid: json["is_bid"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "vehicle_title": vehicleTitle,
        "vehicle_img": vehicleImg,
        "pickup_point": pickupPoint,
        "drop_point": dropPoint,
        "pickup_state": pickupState,
        "drop_state": dropState,
        "amount": amount,
        "weight": weight,
        "amt_type": amtType,
        "total_amt": totalAmt,
        "post_date": postDate.toIso8601String(),
        "load_status": loadStatus,
        "owner_name": ownerName,
        "owner_img": ownerImg,
        "material_name": materialName,
        "load_distance": loadDistance,
        "owner_rating": ownerRating,
        "bid_amount": bidAmount,
        "bid_amount_type": bidAmountType,
        "bid_total_amt": bidTotalAmt,
        "is_bid": isBid,
      };
}
