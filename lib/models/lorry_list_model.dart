// To parse this JSON data, do
//
//     final lorryListModel = lorryListModelFromJson(jsonString);

import 'dart:convert';

LorryListModel lorryListModelFromJson(String str) =>
    LorryListModel.fromJson(json.decode(str));

String lorryListModelToJson(LorryListModel data) => json.encode(data.toJson());

class LorryListModel {
  List<BidLorryDatum> bidLorryData;
  String responseCode;
  String result;
  String responseMsg;

  LorryListModel({
    required this.bidLorryData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory LorryListModel.fromJson(Map<String, dynamic> json) => LorryListModel(
        bidLorryData: List<BidLorryDatum>.from(
            json["BidLorryData"].map((x) => BidLorryDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "BidLorryData": List<dynamic>.from(bidLorryData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class BidLorryDatum {
  String id;
  String lorryImg;
  String lorryTitle;
  String weight;
  String rcVerify;
  String lorryNo;

  BidLorryDatum({
    required this.id,
    required this.lorryImg,
    required this.lorryTitle,
    required this.weight,
    required this.rcVerify,
    required this.lorryNo,
  });

  factory BidLorryDatum.fromJson(Map<String, dynamic> json) => BidLorryDatum(
        id: json["id"],
        lorryImg: json["lorry_img"],
        lorryTitle: json["lorry_title"],
        weight: json["weight"],
        rcVerify: json["rc_verify"],
        lorryNo: json["lorry_no"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lorry_img": lorryImg,
        "lorry_title": lorryTitle,
        "weight": weight,
        "rc_verify": rcVerify,
        "lorry_no": lorryNo,
      };
}
