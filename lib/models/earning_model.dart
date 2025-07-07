// To parse this JSON data, do
//
//     final earningModel = earningModelFromJson(jsonString);

import 'dart:convert';

EarningModel earningModelFromJson(String str) =>
    EarningModel.fromJson(json.decode(str));

String earningModelToJson(EarningModel data) => json.encode(data.toJson());

class EarningModel {
  Earning earning;
  String responseCode;
  String result;
  String responseMsg;

  EarningModel({
    required this.earning,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) => EarningModel(
        earning: Earning.fromJson(json["Earning"]),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "Earning": earning.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Earning {
  String earning;
  String withdrawLimit;

  Earning({
    required this.earning,
    required this.withdrawLimit,
  });

  factory Earning.fromJson(Map<String, dynamic> json) => Earning(
        earning: json["earning"],
        withdrawLimit: json["withdraw_limit"],
      );

  Map<String, dynamic> toJson() => {
        "earning": earning,
        "withdraw_limit": withdrawLimit,
      };
}
