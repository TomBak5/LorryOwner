// To parse this JSON data, do
//
//     final lorrylistModel = lorrylistModelFromJson(jsonString);

import 'dart:convert';

LorrylistModel lorrylistModelFromJson(String str) => LorrylistModel.fromJson(json.decode(str));

String lorrylistModelToJson(LorrylistModel data) => json.encode(data.toJson());

class LorrylistModel {
  List<BidLorryDatum>? bidLorryData;
  String? responseCode;
  String? result;
  String? responseMsg;

  LorrylistModel({
    this.bidLorryData,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory LorrylistModel.fromJson(Map<String, dynamic> json) => LorrylistModel(
    bidLorryData: json["BidLorryData"] == null ? [] : List<BidLorryDatum>.from(json["BidLorryData"]!.map((x) => BidLorryDatum.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "BidLorryData": bidLorryData == null ? [] : List<dynamic>.from(bidLorryData!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class BidLorryDatum {
  String? lorryId;
  String? lorryImg;
  String? lorryTitle;
  String? weight;
  String? rcVerify;
  String? lorryNo;

  BidLorryDatum({
    this.lorryId,
    this.lorryImg,
    this.lorryTitle,
    this.weight,
    this.rcVerify,
    this.lorryNo,
  });

  factory BidLorryDatum.fromJson(Map<String, dynamic> json) => BidLorryDatum(
    lorryId: json["lorry_id"],
    lorryImg: json["lorry_img"],
    lorryTitle: json["lorry_title"],
    weight: json["weight"],
    rcVerify: json["rc_verify"],
    lorryNo: json["lorry_no"],
  );

  Map<String, dynamic> toJson() => {
    "lorry_id": lorryId,
    "lorry_img": lorryImg,
    "lorry_title": lorryTitle,
    "weight": weight,
    "rc_verify": rcVerify,
    "lorry_no": lorryNo,
  };
}
